
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Student
 {
    pub id: u32,
    pub age: u32,
    pub marks: u32,
}


#[starknet::interface]
pub trait IViewFunctions<TContractState> 
{
    fn set_counter(ref self: TContractState, value: u32);

    fn set_owner_name(ref self: TContractState, name: felt252);
    fn update_student(ref self: TContractState, id: u32, age: u32, marks: u32);
    fn increment_counter(ref self: TContractState);
    
    fn get_counter(self: @TContractState) -> u32;
    fn get_owner_name(self: @TContractState) -> felt252;

    fn get_student(self: @TContractState) -> Student;
    fn get_student_marks(self: @TContractState) -> u32;
    fn get_student_age(self: @TContractState) -> u32;

    fn is_student_passed(self: @TContractState) -> bool;
}


#[starknet::contract]
pub mod ViewFunctions {
    // Import the struct and interface we defined above
    use super::{Student, IViewFunctions};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        counter: u32,
        owner_name: felt252,
        student: Student,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.counter.write(0);
        self.owner_name.write('Ali');

        self.student.write(Student {
            id: 1,
            age: 20,
            marks: 95,
        });
    }

    
    #[abi(embed_v0)]
    impl ViewFunctionsImpl of IViewFunctions<ContractState> {
        
        fn set_counter(ref self: ContractState, value: u32) {
            self.counter.write(value);
        }

        fn set_owner_name(ref self: ContractState, name: felt252) {
            self.owner_name.write(name);
        }

        fn update_student(
            ref self: ContractState,
            id: u32,
            age: u32,
            marks: u32,
        ) {
            assert(marks <= 100, 'Invalid Marks');
            assert(age > 0, 'Invalid Age');

            self.student.write(Student {
                id: id,
                age: age,
                marks: marks,
            });
        }

        fn increment_counter(ref self: ContractState) {
            let current_counter = self.counter.read();
            self.counter.write(current_counter + 1);
        }

        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn get_owner_name(self: @ContractState) -> felt252 {
            self.owner_name.read()
        }

        fn get_student(self: @ContractState) -> Student {
            self.student.read()
        }

        fn get_student_marks(self: @ContractState) -> u32 {
            let student_data = self.student.read();
            student_data.marks
        }

        fn get_student_age(self: @ContractState) -> u32 {
            let student_data = self.student.read();
            student_data.age
        }

        fn is_student_passed(self: @ContractState) -> bool {
            let student_data = self.student.read();

            if student_data.marks >= 50 {
                true
            } else {
                false
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{ViewFunctions, IViewFunctions};

    #[test]
    fn test_counter_functions() {
        let mut state = ViewFunctions::contract_state_for_testing();

        let initial_counter = state.get_counter();
        assert(initial_counter == 0, 'Initial Counter Failed');

        state.set_counter(10);

        let updated_counter = state.get_counter();
        assert(updated_counter == 10, 'Set Counter Failed');

        state.increment_counter();

        let incremented_counter = state.get_counter();
        assert(incremented_counter == 11, 'Increment Failed');
    }

    #[test]
    fn test_owner_name() {
        let mut state = ViewFunctions::contract_state_for_testing();

        state.set_owner_name('Ahmed');

        let owner = state.get_owner_name();

        assert(owner == 'Ahmed', 'Owner Name Failed');
    }

    #[test]
    fn test_student_update() {
        let mut state = ViewFunctions::contract_state_for_testing();

        state.update_student(5, 22, 88);

        let student = state.get_student();

        assert(student.id == 5, 'Student ID Failed');
        assert(student.age == 22, 'Student Age Failed');
        assert(student.marks == 88, 'Student Marks Failed');
    }

    #[test]
    fn test_student_pass_status() {
        let mut state = ViewFunctions::contract_state_for_testing();

        state.update_student(1, 20, 75);

        let passed = state.is_student_passed();

        assert(passed == true, 'Pass Status Failed');
    }

    #[test]
    fn test_student_fail_status() {
        let mut state = ViewFunctions::contract_state_for_testing();

        state.update_student(1, 20, 30);

        let passed = state.is_student_passed();

        assert(passed == false, 'Fail Status Failed');
    }
}