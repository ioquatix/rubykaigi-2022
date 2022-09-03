# Fiber Scheduler Hooks

The Ruby `Fiber.scheduler` interface provides hooks for blocking operations, and can schedule these blocking operations in the event loop. While waiting for the event to completel other fibers can execute. This is sometimes called green threads.

You can see a complete implementation of this interface in [async](https://github.com/socketry/async/blob/main/lib/async/scheduler.rb).

## Usage

The scripts in this directory show the different hooks and how they behave. You can run those programs individually and inspect the code to confirm for yourself that the blocking operations run concurrently (internally non-blocking).
