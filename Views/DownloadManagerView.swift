import SwiftUI

struct TestamentSection: View {
    let testament: Testament
    @ObservedObject var viewModel: DownloadManagerViewModel
    
    var body: some View {
        Section(testament.rawValue) {
            ForEach(viewModel.booksForTestament(testament), id: \.self) { book in
                HStack {
                    Text(book)
                    Spacer()
                    if viewModel.downloadedBooks.contains(book) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if viewModel.downloadingBooks.contains(book) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Button {
                            Task {
                                await viewModel.downloadBook(book)
                            }
                        } label: {
                            Image(systemName: "arrow.down.circle")
                        }
                    }
                }
            }
        }
    }
}

struct DownloadManagerView: View {
    @StateObject private var viewModel = DownloadManagerViewModel()
    
    var body: some View {
        List {
            TestamentSection(testament: .old, viewModel: viewModel)
            TestamentSection(testament: .new, viewModel: viewModel)
        }
        .navigationTitle("Download Traditional Verses")
        .alert("Download Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NavigationStack {
        DownloadManagerView()
    }
}
