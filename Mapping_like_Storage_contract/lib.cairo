// ===========================================================
//  TOPIC   : Mappings (LegacyMap) in Cairo / StarkNet
//  CONTRACT: GradeBook — A Student Grade Management System
// ===========================================================


#[starknet::interface]
trait IGradeBook<TContractState> {
    fn register_student(ref self: TContractState, name: felt252);

    fn assign_grade(
        ref self: TContractState,
        student: starknet::ContractAddress,
        grade: u8
    );

    fn assign_subject_grade(
        ref self: TContractState,
        student: starknet::ContractAddress,
        subject_id: u8,
        grade: u8
    );

    fn get_grade(
        self: @TContractState,
        student: starknet::ContractAddress
    ) -> u8;

    fn get_subject_grade(
        self: @TContractState,
        student: starknet::ContractAddress,
        subject_id: u8
    ) -> u8;

    fn get_student_name(
        self: @TContractState,
        student: starknet::ContractAddress
    ) -> felt252;

    fn is_student_registered(
        self: @TContractState,
        student: starknet::ContractAddress
    ) -> bool;

    fn get_total_students(self: @TContractState) -> u32;
}

// ----------------------------------------------------------
// CONTRACT MODULE
// ----------------------------------------------------------
#[starknet::contract]
mod GradeBook {

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    // ======================================================
    //  STORAGE
    //  All data stored permanently on-chain lives here.
    //
    //  KEY CONCEPT: LegacyMap::<KeyType, ValueType>
    //  ──────────────────────────────────────────────
    //  This is Cairo's mapping type (like a giant dictionary).
    //  Any key never written returns ZERO/FALSE by default.
    //  Read with: .read(key) | Write with: .write(key, value)
    // ======================================================
    #[storage]
    struct Storage {
        // grades: Key = Student Address, Value = Grade (0-100)
        grades: LegacyMap::<ContractAddress, u8>,

        // student_names: Key = Student Address, Value = Name (felt252 short string)
        student_names: LegacyMap::<ContractAddress, felt252>,

        // is_registered: Key = Student Address, Value = Boolean status
        is_registered: LegacyMap::<ContractAddress, bool>,

        // subject_grades: Key = Tuple (Student Address, Subject ID), Value = Grade
        // Cairo uses tuple keys instead of multi-dimensional/nested mappings.
        subject_grades: LegacyMap::<(ContractAddress, u8), u8>,

        // State variables for access control and tracking
        teacher: ContractAddress,  
        student_count: u32,        
    }

    // ======================================================
    //  EVENTS — Notify the outside world about state changes
    // ======================================================
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StudentRegistered: StudentRegistered,
        GradeAssigned: GradeAssigned,
        SubjectGradeAssigned: SubjectGradeAssigned,
    }

    #[derive(Drop, starknet::Event)]
    struct StudentRegistered {
        student: ContractAddress,
        name: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct GradeAssigned {
        student: ContractAddress,
        grade: u8,
    }

    #[derive(Drop, starknet::Event)]
    struct SubjectGradeAssigned {
        student: ContractAddress,
        subject_id: u8,
        grade: u8,
    }

    // ======================================================
    //  CONSTRUCTOR — Runs once during contract deployment
    // ======================================================
    #[constructor]
    fn constructor(ref self: ContractState) {
        let deployer = get_caller_address();
        self.teacher.write(deployer); // Sets the deployer as the authorized teacher
        self.student_count.write(0_u32);
    }

    // ======================================================
    //  PUBLIC FUNCTIONS (Implementation of the Interface)
    // ======================================================
    #[abi(embed_v0)]
    impl GradeBookImpl of super::IGradeBook<ContractState> {

        // Allows any unique address to register themselves with a name
        fn register_student(ref self: ContractState, name: felt252) {
            let caller = get_caller_address();

            // Guard check: Ensure the student hasn't registered already
            let already = self.is_registered.read(caller);
            assert(!already, 'Already registered');

            // Writing values into mappings using the caller's address as key
            self.student_names.write(caller, name);
            self.is_registered.write(caller, true);

            // Increment the counter tracker
            let count = self.student_count.read();
            self.student_count.write(count + 1_u32);

            self.emit(StudentRegistered { student: caller, name });
        }

        // Allows only the designated teacher to assign global grades to registered students
        fn assign_grade(ref self: ContractState, student: ContractAddress, grade: u8) {
            let caller = get_caller_address();
            let teacher = self.teacher.read();
            assert(caller == teacher, 'Only teacher allowed');
            assert(grade <= 100_u8, 'Grade must be 0 to 100');

            // Verify target student exists in system
            let registered = self.is_registered.read(student);
            assert(registered, 'Student not registered');

            // Update the storage mapping
            self.grades.write(student, grade);

            self.emit(GradeAssigned { student, grade });
        }

        // Allows teacher to assign specialized subject grades using a composite Tuple Key
        fn assign_subject_grade(
            ref self: ContractState,
            student: ContractAddress,
            subject_id: u8,
            grade: u8
        ) {
            let caller = get_caller_address();
            let teacher = self.teacher.read();
            assert(caller == teacher, 'Only teacher allowed');
            assert(grade <= 100_u8, 'Grade must be 0 to 100');

            let registered = self.is_registered.read(student);
            assert(registered, 'Student not registered');

            // Using tuple (student, subject_id) as the unique identifier key
            self.subject_grades.write((student, subject_id), grade);

            self.emit(SubjectGradeAssigned { student, subject_id, grade });
        }

        // Read overall grade from storage
        fn get_grade(self: @ContractState, student: ContractAddress) -> u8 {
            self.grades.read(student)
        }

        // Read specific subject grade using composite Tuple Key
        fn get_subject_grade(
            self: @ContractState,
            student: ContractAddress,
            subject_id: u8
        ) -> u8 {
            self.subject_grades.read((student, subject_id))
        }

        // Read student name string
        fn get_student_name(self: @ContractState, student: ContractAddress) -> felt252 {
            self.student_names.read(student)
        }

        // Read registration status bool
        fn is_student_registered(self: @ContractState, student: ContractAddress) -> bool {
            self.is_registered.read(student)
        }

        // Read total active counter variable
        fn get_total_students(self: @ContractState) -> u32 {
            self.student_count.read()
        }
    }

    // ======================================================
    //  UNIT TESTS — Verifies Storage & Mapping Behaviors
    // ======================================================
    #[cfg(test)]
    mod tests {
        use super::GradeBook;
        use starknet::testing::set_caller_address;
        use starknet::contract_address_const;

        // Mock addresses for localized execution environment
        fn student_ali() -> starknet::ContractAddress {
            contract_address_const::<0x2>()
        }
        fn student_sara() -> starknet::ContractAddress {
            contract_address_const::<0x3>()
        }
        fn unknown() -> starknet::ContractAddress {
            contract_address_const::<0x99>()
        }

        #[test]
        fn test_unregistered_returns_false() {
            let state = GradeBook::contract_state_for_testing();
            let result = GradeBook::GradeBookImpl::is_student_registered(@state, unknown());
            assert(result == false, 'Should be false by default');
        }

        #[test]
        fn test_default_grade_is_zero() {
            let state = GradeBook::contract_state_for_testing();
            let grade = GradeBook::GradeBookImpl::get_grade(@state, unknown());
            assert(grade == 0_u8, 'Default grade should be 0');
        }

        #[test]
        fn test_register_writes_to_mappings() {
            set_caller_address(student_ali());
            let mut state = GradeBook::contract_state_for_testing();

            GradeBook::GradeBookImpl::register_student(ref state, 'Ali');

            let name = GradeBook::GradeBookImpl::get_student_name(@state, student_ali());
            assert(name == 'Ali', 'Name mapping incorrect');

            let registered = GradeBook::GradeBookImpl::is_student_registered(@state, student_ali());
            assert(registered == true, 'Registration mapping incorrect');
        }

        #[test]
        fn test_two_students_have_separate_mapping_entries() {
            // Context switch simulation for Student Ali
            set_caller_address(student_ali());
            let mut state = GradeBook::contract_state_for_testing();
            GradeBook::GradeBookImpl::register_student(ref state, 'Ali');

            // Context switch simulation for Student Sara
            set_caller_address(student_sara());
            GradeBook::GradeBookImpl::register_student(ref state, 'Sara');

            let ali_name  = GradeBook::GradeBookImpl::get_student_name(@state, student_ali());
            let sara_name = GradeBook::GradeBookImpl::get_student_name(@state, student_sara());
            assert(ali_name  == 'Ali',  'Ali name wrong');
            assert(sara_name == 'Sara', 'Sara name wrong');

            let count = GradeBook::GradeBookImpl::get_total_students(@state);
            assert(count == 2_u32, 'Count should be 2');
        }
    }
}