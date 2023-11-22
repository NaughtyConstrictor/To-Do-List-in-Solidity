# To-Do list simple contract in Solidity


The `TodoList` contract is designed to manage tasks within the Ethereum blockchain. I tried to offer flexibility, allowing users to tailor the contract's complexity according to their needs with the provided functionality which was sufficient for me to get some familirity with smart contracts in Solidity, although, obviously, one can add more functionality and thus more complexity to suit his needs.


## Description and Purpose

The `TodoList` contract is designed to manage a list of tasks. It introduces a structure `Task` that includes essential details such as task ID, description, and completion status.

**Modifiers:**

- `onlyOwner`: Ensures that only the contract owner can execute specific functions. This modifier enhances security by restricting access to critical operations.
- `taskExists`: Validates whether a task with a given ID exists before executing certain functions. This modifier helps prevent errors resulting from non-existent tasks.
- `updateState`: Updates state variables upon modifications, to ensure efficient tracking of contract state changes.

**State Variables:**

- `_owner`: Stores the address of the contract owner.
- `_tasks`: Maps task IDs to their respective Task struct, maintaining task details.
- `_task_ids`: An array storing task IDs to manage task operations.
- `_task_count`: Tracks the total count of tasks.
- `_completed_tasks_ids, _completed_tasks, _incomplete_tasks_ids, _incomplete_tasks`: Arrays to store completed and incomplete tasks separately.
- `_tasks_state, _update_state`: Variables tracking the contract's state and updates for efficient caching.
- `_task_count`: Keeps track of the total count of tasks.

**Functions and Core Operations:**

The contract provides several essential operations:

- `create_task`: Enables the contract owner to add a new task to the list by providing a description. It increments the task count and emits a TaskCreated event.

- `complete_task`: Permits the contract owner to mark a specific task as completed. It updates the task's completion status and emits a TaskCompleted event.

- `complete_all_tasks`: Marks all existing tasks as completed, facilitating bulk task completion, emitting an AllTasksCompleted event.

- `delete_task`: Allows the contract owner to delete a specific task by its ID. It removes the task details, adjusts the task ID array, and emits a TaskDeleted event.

- `delete_completed_tasks`: Deletes all completed tasks, updating the task lists accordingly and emitting a CompletedTasksDeleted event.

- `delete_all_tasks`: Deletes all existing tasks, resetting the task IDs array and count, allowing a clean slate.

- `update_task`: Allows the contract owner to modify a task's description or completion status. It emits a TaskUpdated event after updating the task details.

**Public Functions for Viewing Tasks:**

- `get_task_ids`: Provides an array containing current task IDs.
- `get_tasks`: Retrieves an array of available tasks along with their details.

**Private Helper Functions:**

- `_task_exists`: Checks whether a task with a given ID exists in the task IDs array.
- `_delete_task_id`: Removes a specific task ID from the task IDs array.

**Events:**

The contract emits various events (`TaskCreated`, `TaskCompleted`, `TaskDeleted`, `TaskUpdated`, `AllTasksDeleted`, and `AllTasksCompleted`) to notify users about specific actions performed on tasks.

## Explanation of some of the choices made

**Returning an Array Instead of a Mapping:**
Solidity doesn't allow directly returning a mapping from a function, so an array of task IDs (`_task_ids`) was introduced to maintain the order of tasks. This array serves as an index to iterate through the `_tasks` mapping when managing tasks.

**Utilizing Task IDs Array:**
The `_task_ids` array is crucial, especially when deleting tasks from the middle. It enables proper iteration through the `_tasks` mapping, even after deleting specific tasks. This approach ensures consistent access to task details without leaving gaps in the iteration.

**Task Count for Generating IDs:**
The `_task_count` variable is used for generating task IDs. Incrementing this count with each newly created task guarantees a unique identifier for each task. This unique ID generation is crucial for task identification and management.

**Importance of Modifiers:**
The `onlyOwner` modifier restricts access to certain functions, allowing only the contract owner to execute critical operations. This enhances security and prevents unauthorized users from modifying or deleting tasks.

The `taskExists` modifier ensures that tasks are verified to exist before executing specific functions. It prevents errors that might arise from attempting operations on non-existent tasks, enhancing the robustness of the contract.

**Logic Behind Deleting Tasks in `_task_ids` Array:**
When deleting a task from the middle of the `_task_ids` array, shifting the array elements was chosen over directly deleting an element. This ensures the array remains contiguous, preserving the order of tasks and facilitating proper iteration.

**Use of State Variables for Efficiency and Caching**
The decision to utilize state variables like `_update_state` and `_tasks_state` was motivated by the aim to optimize the retrieval of completed and incomplete tasks.  
While an alternative approach could have involved updating arrays upon task creation or completion, this might have complicated individual functions, straying from the single responsibility principle.   
Additionally, managing updates across multiple arrays (task IDs, completed tasks, and incomplete tasks) would introduce complexities in deletions and updates, potentially increasing gas costs.   
By calculating arrays upon user request only, the code adheres to a more efficient strategy, deferring the computation of task status arrays until necessary. This approach aligns with the principle of separating concerns, fostering cleaner, more readable, and efficient code.

**Deletion of All Tasks:**
Clearing the `_task_ids` array and resetting the `_task_count` when deleting all tasks is more efficient than deleting tasks one by one. In Solidity, removing elements from mappings is complex and not recommended for efficiency reasons. Thus, creating a new empty array for task IDs is a straightforward and efficient approach.

**Function Overloading for Update Task:**
Solidity doesn't natively support default argument values. Therefore, overloading the `update_task` function allows flexibility in updating tasks by either modifying the description or setting completion status, accommodating various use cases.

These choices, considering Solidity's limitations and efficiency concerns, contribute to creating a robust TodoList contract for managing tasks securely and efficiently on the Ethereum blockchain.

## Conclusion

The `TodoList` contract demonstrates management of tasks in a smart contract environment, adhering to Solidity's constraints and best practices. Utilizing arrays in tandem with mappings and employing modifiers for access control enhances security and efficiency in task management. The contract's design ensures task integrity while addressing limitations posed by Solidity's data structures and language features.

The explanations provided align with the code's functionalities and Solidity's peculiarities. However, these decisions were made based on Solidity's constraints, and any adjustments would have to consider the limitations and characteristics of the language.


## Resources
- [What Are Solidity Modifiers? Explained with Examples](https://www.freecodecamp.org/news/what-are-solidity-modifiers/) by Chigozie Oduah (freeCodeCamp)
- [Solidity by Example](https://docs.soliditylang.org/en/v0.8.23/solidity-by-example.html) (Solidity Documentation)
- [Solidity: Types](https://docs.soliditylang.org/en/v0.8.23/types.html) (Solidity Documentation)
- [How to push onto a dynamic sized Array within a function with Solidity?](https://stackoverflow.com/questions/69678541/how-to-push-onto-a-dynamic-sized-array-within-a-function-with-solidity/75574734#75574734) by Adham (StackOverflow)
- [How to delete a mapping?](https://ethereum.stackexchange.com/questions/15553/how-to-delete-a-mapping) (Ethereum Stack Exchange)
- [Improper Array Deletion in Solidity](https://blog.solidityscan.com/improper-array-deletion-82672eed8e8d#:~:text=In%20Solidity%2C%20we%20remove%20an,getLength()%20and%20removeItem().) by Shashank (SolidityScan)
- [How to set default parameters to functions in Solidity](https://stackoverflow.com/a/52119029) by Adam Kipnis (StackOverflow)