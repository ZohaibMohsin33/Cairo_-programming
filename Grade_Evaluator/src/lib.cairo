// Specifies that this module represents a deployable Starknet smart contract
#[starknet::contract]
mod GradeEvaluator {
    // Import necessary types from the Starknet core library
    use starknet::{ContractAddress, get_caller_address};
    
    // Import the absolute latest storage access traits required by modern Cairo
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess,
        StorageMapReadAccess, StorageMapWriteAccess, Map
    };

    // Define a custom structure to securely bundle a student's academic metrics
    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub struct GradeRecord {
        pub score: u8,       // Unsigned 8-bit integer for scores (0-100)
        pub letter_grade: felt252, // Cairo's native type to store short text like 'A', 'B', 'C'
    }

    // Storage block: Defines variables permanently saved on the blockchain state
    #[storage]
    struct Storage {
        instructor: ContractAddress, // Stores the wallet address of the authorized grader
        grades: Map::<ContractAddress, GradeRecord>, // Modern mapping format replacing LegacyMap
    }

    // The Constructor executes exactly once when the smart contract is deployed
    #[constructor]
    fn constructor(ref self: ContractState, instructor_address: ContractAddress) {
        // Designate the deploying address as the official contract admin/instructor
        self.instructor.write(instructor_address);
    }

    // Public functions accessible by external users or applications
    #[abi(embed_v0)]
    impl GradeEvaluatorImpl of super::IGradeEvaluator<ContractState> {
        
        // State-changing function: Evaluates score and saves the record to the ledger
        fn evaluate_and_submit_grade(ref self: ContractState, student: ContractAddress, score: u8) {
            // Access Control: Ensure only the instructor can submit grades
            let caller = get_caller_address();
            assert(caller == self.instructor.read(), 'Only instructor can grade');

            // Data Validation: Ensure the score lies within standard boundaries
            assert(score <= 100_u8, 'Score cannot exceed 100');

            // Evaluation Logic: Conditional branching to map numerical scores to letter grades
            let letter = if score >= 90_u8 {
                'A'
            } else if score >= 80_u8 {
                'B'
            } else if score >= 70_u8 {
                'C'
            } else if score >= 60_u8 {
                'D'
            } else {
                'F'
            };

            // Package data into our custom GradeRecord struct
            let new_record = GradeRecord { score: score, letter_grade: letter };

            // Commit the record permanently to the blockchain mapping
            self.grades.write(student, new_record);
        }

        // View function: Publicly accessible, read-only lookup for student records
        fn get_student_grade(self: @ContractState, student: ContractAddress) -> GradeRecord {
            // Read and return the requested structural data directly from state storage
            self.grades.read(student)
        }

        // View function: Publicly accessible lookup to see who owns/manages the evaluator
        fn get_instructor(self: @ContractState) -> ContractAddress {
            self.instructor.read()
        }
    }
}

// Global interface declaring the functions our contract is required to implement
#[starknet::interface]
pub trait IGradeEvaluator<TContractState> {
    fn evaluate_and_submit_grade(ref self: TContractState, student: starknet::ContractAddress, score: u8);
    fn get_student_grade(self: @TContractState, student: starknet::ContractAddress) -> GradeEvaluator::GradeRecord;
    fn get_instructor(self: @TContractState) -> starknet::ContractAddress;
}