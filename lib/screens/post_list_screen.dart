import 'package:flutter/material.dart';

import '../model/post.dart';
import '../services/api_service.dart';
import 'post_detail_screen.dart';

// ── Threads light palette ─────────────────────────────────────────────────────
const _bg = Color(0xFFFFFFFF);
const _divider = Color(0xFFE5E5E5);
const _textPrimary = Color(0xFF0D0D0D);
const _textSecondary = Color(0xFF767676);
const _accent = Color(0xFF7B2CFF);
// ─────────────────────────────────────────────────────────────────────────────

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _apiService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        centerTitle: true,
        title: const Text(
          'Threads',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _textPrimary, size: 22),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _divider, height: 1),
        ),
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar las publicaciones',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
            );
          }
          final posts = snapshot.data ?? [];
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: posts.length,
            separatorBuilder: (context, index) =>
                Container(height: 1, color: _divider),
            itemBuilder: (context, index) {
              final post = posts[index];
              final isLast = index == posts.length - 1;
              return _ThreadCard(
                post: post,
                showLine: !isLast,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({
    required this.post,
    required this.onTap,
    required this.showLine,
  });

  final Post post;
  final VoidCallback onTap;
  final bool showLine;

  static const _avatarColors = [
    Color(0xFF7B2CFF), Color(0xFF00B2FF), Color(0xFFFF4FD8),
    Color(0xFF0E9E6E), Color(0xFFFF6B35), Color(0xFF1A73E8),
    Color(0xFF9C27B0), Color(0xFF00897B), Color(0xFFE91E63), Color(0xFF5C6BC0),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[post.userId % _avatarColors.length];
    final likesCount = (post.id * 17) % 500 + 50;
    final repliesCount = (post.id * 3) % 20 + 1;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left column: avatar + thread line ──────────────────────────
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: avatarColor,
                    child: Text(
                      post.userId.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (showLine)
                    Container(
                      width: 2,
                      height: 48,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Right column: content ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header row
                  Row(
                    children: [
                      Text(
                        'usuario_${post.userId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '·  ahora',
                        style: TextStyle(fontSize: 13, color: _textSecondary),
                      ),
                      const Spacer(),
                      const Icon(Icons.more_horiz, size: 20, color: _textSecondary),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // title
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // body
                  Text(
                    post.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textPrimary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // action bar
                  Row(
                    children: [
                      _ThreadAction(
                        icon: Icons.favorite_border,
                        label: '$likesCount',
                      ),
                      const SizedBox(width: 20),
                      _ThreadAction(
                        icon: Icons.chat_bubble_outline,
                        label: '$repliesCount',
                        onTap: onTap,
                      ),
                      const SizedBox(width: 20),
                      const _ThreadAction(icon: Icons.repeat_rounded, label: ''),
                      const SizedBox(width: 20),
                      const _ThreadAction(icon: Icons.send_outlined, label: ''),
                    ],
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadAction extends StatelessWidget {
  const _ThreadAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: _textSecondary),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: _textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
