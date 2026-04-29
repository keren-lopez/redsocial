import 'package:flutter/material.dart';

import '../model/comment.dart';
import '../model/post.dart';
import '../model/user.dart';
import '../services/api_service.dart';

// ── Threads light palette ─────────────────────────────────────────────────────
const _bg = Color(0xFFFFFFFF);
const _divider = Color(0xFFE5E5E5);
const _textPrimary = Color(0xFF0D0D0D);
const _textSecondary = Color(0xFF767676);
const _accent = Color(0xFF7B2CFF);
// ─────────────────────────────────────────────────────────────────────────────

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});
  final int postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<_PostDetailData> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<_PostDetailData> _loadDetail() async {
    final post = await _apiService.getPostDetail(widget.postId);
    final results = await Future.wait([
      _apiService.getUser(post.userId),
      _apiService.getCommentsByPost(post.id),
    ]);
    final user = results[0] as User;
    final comments = results[1] as List<Comment>;
    return _PostDetailData(post: post, user: user, comments: comments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Hilo',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: _textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _divider, height: 1),
        ),
      ),
      body: FutureBuilder<_PostDetailData>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'No se pudo cargar el detalle',
                style: TextStyle(color: _textSecondary),
              ),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _PostThread(post: data.post, user: data.user),
              Container(height: 1, color: _divider),
              _RepliesHeader(count: data.comments.length),
              ...data.comments.map(
                (c) => _ReplyThread(comment: c, isLast: c == data.comments.last),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _PostDetailData {
  _PostDetailData({required this.post, required this.user, required this.comments});
  final Post post;
  final User user;
  final List<Comment> comments;
}

// ── Main post ─────────────────────────────────────────────────────────────────

class _PostThread extends StatelessWidget {
  const _PostThread({required this.post, required this.user});
  final Post post;
  final User user;

  static const _avatarColors = [
    Color(0xFF7B2CFF), Color(0xFF00B2FF), Color(0xFFFF4FD8),
    Color(0xFF0E9E6E), Color(0xFFFF6B35), Color(0xFF1A73E8),
    Color(0xFF9C27B0), Color(0xFF00897B), Color(0xFFE91E63), Color(0xFF5C6BC0),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[post.userId % _avatarColors.length];
    final likesCount = (post.id * 17) % 500 + 50;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left column ───────────────────────────────────────────────────
          SizedBox(
            width: 42,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: avatarColor,
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 32,
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

          // ── Right column ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // user info row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: _textPrimary,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _divider, width: 1.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Seguir',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 6),

                // body
                Text(
                  post.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textPrimary,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 14),

                // meta line
                Text(
                  'Hace un momento  ·  ${user.city}',
                  style: const TextStyle(fontSize: 13, color: _textSecondary),
                ),

                const SizedBox(height: 14),

                Container(height: 1, color: _divider),

                const SizedBox(height: 12),

                // action bar
                Row(
                  children: [
                    _DetailAction(icon: Icons.favorite_border, label: '$likesCount Me gusta'),
                    const SizedBox(width: 20),
                    _DetailAction(icon: Icons.chat_bubble_outline, label: 'Responder'),
                    const SizedBox(width: 20),
                    const _DetailAction(icon: Icons.repeat_rounded, label: 'Repostear'),
                    const Spacer(),
                    const _DetailAction(icon: Icons.send_outlined, label: ''),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Replies ───────────────────────────────────────────────────────────────────

class _RepliesHeader extends StatelessWidget {
  const _RepliesHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        'Respuestas  ·  $count',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    );
  }
}

class _ReplyThread extends StatelessWidget {
  const _ReplyThread({required this.comment, required this.isLast});
  final Comment comment;
  final bool isLast;

  static const _avatarColors = [
    Color(0xFF7B2CFF), Color(0xFF00B2FF), Color(0xFFFF4FD8),
    Color(0xFF0E9E6E), Color(0xFFFF6B35), Color(0xFF1A73E8),
    Color(0xFF9C27B0), Color(0xFF00897B), Color(0xFFE91E63), Color(0xFF5C6BC0),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[comment.id % _avatarColors.length];
    final likesCount = (comment.id * 7) % 50 + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left column ───────────────────────────────────────────────────
          SizedBox(
            width: 42,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: avatarColor,
                  child: Text(
                    comment.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: _divider,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right column ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.name.split(' ').first,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '·  ahora',
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, size: 18, color: _textSecondary),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  comment.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textPrimary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: _textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '$likesCount',
                      style: const TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.chat_bubble_outline, size: 16, color: _textSecondary),
                    const SizedBox(width: 4),
                    const Text(
                      'Responder',
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared action widget ──────────────────────────────────────────────────────

class _DetailAction extends StatelessWidget {
  const _DetailAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _textSecondary),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 13, color: _textSecondary)),
        ],
      ],
    );
  }
}
