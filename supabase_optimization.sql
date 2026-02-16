-- Database Performance Optimization Indexes for Fitness Coach
-- Path: supabase_optimization.sql

-- 1. Workouts Table Indexes
-- Essential for sorting workout history and calendar by date
CREATE INDEX IF NOT EXISTS idx_workouts_date ON public.workouts (date DESC);

-- Essential for RLS and user-specific queries
CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON public.workouts (user_id);

-- Compound index for very fast retrieval of a user's latest workouts (History Screen)
CREATE INDEX IF NOT EXISTS idx_workouts_user_date ON public.workouts (user_id, date DESC);


-- 2. Workout Exercises Table Indexes
-- Essential for analytics and PR detection (filtering by exercise name across all workouts)
CREATE INDEX IF NOT EXISTS idx_workout_exercises_name ON public.workout_exercises (exercise_name);

-- Essential for efficient Joins (Workout -> Exercises)
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout_id ON public.workout_exercises (workout_id);


-- 3. Workout Sets Table Indexes
-- Essential for efficient Joins (Exercise -> Sets)
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise_id ON public.workout_sets (workout_exercise_id);


-- 4. Routines Table Indexes
-- Essential for fetching a user's custom routines
CREATE INDEX IF NOT EXISTS idx_routines_user_id ON public.routines (user_id);


-- 5. Exercise PRs Table Indexes (if table exists)
-- Essential for PR lookups during workout sessions
DO $$ 
BEGIN 
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'exercise_prs') THEN
        CREATE INDEX IF NOT EXISTS idx_exercise_prs_user_name ON public.exercise_prs (user_id, exercise_name);
    END IF;
END $$;
