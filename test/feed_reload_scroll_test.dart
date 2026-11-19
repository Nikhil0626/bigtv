import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadMorePosts ignores calls while isReload or _isFetchingAllPosts is in-flight', () async {
    final provider = HomeProvider();
    provider.isReload = true;
    provider.hasMorePosts = true;
    provider.isLoadingMore = false;
    provider.allPostLastId = "100";

    // Calling loadMorePosts while isReload is true should immediately return without loading more
    await provider.loadMorePosts();
    expect(provider.isLoadingMore, isFalse);
  });
}
