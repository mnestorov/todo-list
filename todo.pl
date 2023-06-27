#!/usr/bin/perl

# Import the necessary modules
use strict;
use warnings;
use Storable qw(store retrieve);
use Time::Piece;

# Define the filename where the tasks will be stored
my $filename = 'todo_list';

# Define the array that will hold the tasks
my @to_do_list;

# If the file exists when the script starts, load the tasks from it
if (-e $filename) {
    @to_do_list = @{ retrieve($filename) };
}

# Main loop
while (1) {
    # Print the menu
    print "What would you like to do?\n";
    print "1. Add task\n";
    print "2. Display tasks\n";
    print "3. Delete task\n";
    print "4. Mark task as completed\n";
    print "5. Show upcoming tasks\n";
    print "6. Exit\n";
    print "Enter your choice: ";

    # Get the user's choice
    my $choice = <STDIN>;
    chomp $choice;

    # Perform the appropriate action
    if ($choice == 1) {
        # Add task
        print "Enter the task: ";
        my $task = <STDIN>;
        chomp $task;
        print "Enter the priority (1-5, 1 being highest): ";
        my $priority = <STDIN>;
        chomp $priority;
        print "Enter the due date in days from today: ";
        my $due_date = <STDIN>;
        chomp $due_date;
        my $now = localtime;
        # Convert the due date from days to a specific date
        my $due_date_time = $now + ($due_date * 24 * 60 * 60);
        # Add the task to the list
        push @to_do_list, { task => $task, priority => $priority, completed => 0, due_date => $due_date_time->strftime('%Y-%m-%d') };
        print "Task added to the list.\n";

    } elsif ($choice == 2) {
        # Display tasks
        # Sort the list by priority
        @to_do_list = sort { $a->{priority} <=> $b->{priority} } @to_do_list;
        print "\nYour tasks are:\n";
        # Loop through the tasks and print each one
        for my $i (0..$#to_do_list) {
            # Skip the task if it's completed
            next if $to_do_list[$i]->{completed};
            print ($i + 1) . ". " . $to_do_list[$i]->{task} . " (priority: " . $to_do_list[$i]->{priority} . ", due date: " . $to_do_list[$i]->{due_date} . ")\n";
        }
        print "\n";

    } elsif ($choice == 3) {
        # Delete task
        # Check if there are any tasks to delete
        if (@to_do_list) {
            print "Enter the number of the task you want to delete: ";
            my $task_num = <STDIN>;
            chomp $task_num;
            # Check if the task number is valid
            if($task_num > 0 and $task_num <= scalar(@to_do_list)) {
                # Remove the task from the list
                splice(@to_do_list, $task_num - 1, 1);
                print "Task deleted.\n";
            } else {
                print "Invalid task number.\n";
            }
        } else {
            print "Your task list is empty. Nothing to delete.\n";
        }

    } elsif ($choice == 4) {
        # Mark task as completed
        # Check if there are any tasks to mark as completed
        if (@to_do_list) {
            print "Enter the number of the task you want to mark as completed: ";
            my $task_num = <STDIN>;
            chomp $task_num;
            # Check if the task number is valid
            if($task_num > 0 and $task_num <= scalar(@to_do_list)) {
                # Mark the task as completed
                $to_do_list[$task_num - 1]->{completed} = 1;
                print "Task marked as completed.\n";
            } else {
                print "Invalid task number.\n";
            }
        } else {
            print "Your task list is empty. Nothing to mark as completed.\n";
        }

    } elsif ($choice == 5) {
        # Show upcoming tasks
        my $now = localtime;
        print "\nUpcoming tasks:\n";
        # Loop through the tasks
        for my $i (0..$#to_do_list) {
            # Get the due date of the task
            my $due_date = Time::Piece->strptime($to_do_list[$i]->{due_date}, '%Y-%m-%d');
            # If the task is due within the next three days, print it
            if ($due_date - $now < 3 * 24 * 60 * 60) {
                print ($i + 1) . ". " . $to_do_list[$i]->{task} . " (priority: " . $to_do_list[$i]->{priority} . ", due date: " . $to_do_list[$i]->{due_date} . ")\n";
            }
        }
        print "\n";

    } elsif ($choice == 6) {
        # Exit
        # Save the tasks to the file
        print "Saving and exiting...\n";
        store \@to_do_list, $filename;
        # End the loop and exit the script
        last;

    } else {
        # Invalid choice
        print "Invalid option. Please try again.\n";
    }
}
