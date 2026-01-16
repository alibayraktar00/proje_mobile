import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_log_model.dart';

class TaskManagerTab extends ConsumerWidget {
  const TaskManagerTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutProvider);
    final logs = workoutState.logs;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Workout Diary",
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [Colors.blueGrey.withOpacity(0.2), Colors.transparent]
                        : [Colors.blue.withOpacity(0.05), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded),
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    // Date picker logic can be added here
                    _selectDateFromPicker(context, ref, workoutState.selectedDate);
                  },
                ),
              ),
            ],
          ),

          // Date Strip
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 14, // Last 2 weeks
                // We want to show today first, so we use index 0 as today
                itemBuilder: (context, index) {
                   final date = DateTime.now().subtract(Duration(days: index));
                   final isSelected = _isSameDay(date, workoutState.selectedDate);
                   
                   return GestureDetector(
                     onTap: () => ref.read(workoutProvider.notifier).selectDate(date),
                     child: AnimatedContainer(
                       duration: const Duration(milliseconds: 200),
                       width: 65,
                       margin: const EdgeInsets.only(right: 12),
                       decoration: BoxDecoration(
                         color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                         borderRadius: BorderRadius.circular(24),
                         border: Border.all(
                           color: isSelected ? Colors.transparent : theme.dividerColor.withOpacity(0.1),
                           width: 1,
                         ),
                         boxShadow: [
                           if (isSelected)
                             BoxShadow(
                               color: theme.colorScheme.primary.withOpacity(0.3),
                               blurRadius: 8,
                               offset: const Offset(0, 4),
                             )
                         ],
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(
                             DateFormat('EEE').format(date),
                             style: TextStyle(
                               fontSize: 13,
                               color: isSelected ? Colors.white.withOpacity(0.8) : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                           const SizedBox(height: 6),
                           Text(
                             date.day.toString(),
                             style: TextStyle(
                               fontSize: 20,
                               fontWeight: FontWeight.bold,
                               color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                             ),
                           ),
                         ],
                       ),
                     ),
                   );
                },
              ),
            ),
          ),

          // Stats / Summary
          if (logs.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${logs.length} Exercises", 
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6), 
                        fontWeight: FontWeight.w600
                      )
                    ),
                    Text(
                      "${logs.where((l) => l.isCompleted).length} Completed", 
                      style: TextStyle(
                        color: Colors.green, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ),
            ),

          // Content
          if (workoutState.isLoading)
             const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (logs.isEmpty)
             SliverFillRemaining(
               hasScrollBody: false,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: theme.colorScheme.primary.withOpacity(0.05),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(Icons.fitness_center_rounded, size: 48, color: theme.colorScheme.primary.withOpacity(0.5)),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     "No Records",
                     style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     "No exercises for this date.",
                     style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 14),
                   ),
                 ],
               ),
             )
          else
             SliverList(
               delegate: SliverChildBuilderDelegate(
                 (context, index) {
                   final log = logs[index];
                   return _buildWorkoutCard(context, ref, log, theme);
                 },
                 childCount: logs.length,
               ),
             ),
             
           const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
        ],
      ),
    );
  }

  Future<void> _selectDateFromPicker(BuildContext context, WidgetRef ref, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ref.read(workoutProvider.notifier).selectDate(picked);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildWorkoutCard(BuildContext context, WidgetRef ref, WorkoutLogModel log, ThemeData theme) {
    final isCompleted = log.isCompleted;
    
    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(workoutProvider.notifier).removeLog(log.id);
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20)
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.04), 
               blurRadius: 10, 
               offset: const Offset(0, 4)
             )
          ],
          border: Border.all(
            color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1.5
          )
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
             onTap: () {
                ref.read(workoutProvider.notifier).toggleStatus(log.id);
             },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Custom Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted ? Colors.green : theme.dividerColor,
                        width: 2
                      ),
                    ),
                    child: isCompleted 
                        ? const Icon(Icons.check, size: 18, color: Colors.white) 
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.exerciseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: theme.textTheme.bodyMedium?.color,
                            color: isCompleted 
                                ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5) 
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                              _buildMiniBadge(theme, "${log.sets} Sets", theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              _buildMiniBadge(theme, "${log.reps} Reps", Colors.orange),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMiniBadge(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Text(
        text, 
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)
      ),
    );
  }
}
