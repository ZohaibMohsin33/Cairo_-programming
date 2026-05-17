// Assignment: Traits in Cairo
// Name: Syed Muhammad Abdullah Masood
// Roll No: BSCS22054

trait Describable<T> {
    fn describe(self: @T);
}

#[derive(Drop)]
struct Book {
    title: ByteArray,
}

impl DescribableImpl of Describable<Book> {
    fn describe(self: @Book) {
        println!("Book: {}", self.title);
    }
}

#[executable]
fn main() {
    let book = Book { title: "Cairo for Beginners" };
    book.describe();
}
