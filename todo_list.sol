// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TodoList {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single task.
    struct Task {
        uint256 id; // Identifies a task in the tasks mapping
        string description; // Description of the task
        bool completed; // Indicates whether has been accomplished or not
    }

    address private _owner; // Owner of the contract
    mapping(uint256 => Task) private _tasks; // Mapping of task ID to Task struct
    uint256[] private _task_ids; // Array to store task IDs
    uint256[] private _completed_tasks_ids; // Array to store IDs of completed tasks
    Task[] private _completed_tasks; // Array to store completed tasks
    uint256[] private _incomplete_tasks_ids; // Array to store IDs of incomplete tasks
    Task[] private _incomplete_tasks; // Array to store incomplete tasks
    uint256 private _tasks_state; // State of tasks for caching
    uint256 private _update_state; // State of updates
    uint256 private _task_count; // Total count of tasks

    // Event to trigger when a task is created
    event TaskCreated(uint256 id, string description, bool completed);
    // Event to trigger when a task is completed
    event TaskCompleted(uint256 id, string description, bool completed);
    // Event to trigger when a all tasks have been completed
    event AllTasksCompleted();
    // Event to trigger when a task is deleted
    event TaskDeleted(uint256 id, string description, bool completed);
    //
    event CompletedTasksDeleted(Task[]);
    // Event to trigger when a all tasks have been deleted
    event AllTasksDeleted();
    // Event to trigger when a task is updated
    event TaskUpdated(uint256 id, string description, bool completed);

    // Constructor to initialize state variables
    constructor() {
        _owner = msg.sender;
        _task_count = 0;
        _tasks_state = 0;
        _update_state = 0;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not authorized");
        _;
    }

    // Modifier to check if a task exists
    modifier taskExists(uint256 _id) {
        require(_task_exists(_id), "Task does not exist!");
        _;
    }
    
    // Modifier to update the state upon modifications
    modifier updateState() {
        _;
        ++_update_state;
    }

    // Checks if a task with the given ID exists
    function _task_exists(uint256 _id) private view returns (bool) {
        for (uint256 i = 0; i < _task_ids.length; ++i) {
            if (_task_ids[i] == _id) return true;
        }
        return false;
    }

    // Deletes a task ID from the _task_ids array
    function _delete_task_id(uint256 _id) private updateState {
        for (uint256 i = 0; i < _task_ids.length; ++i) {
            if (_task_ids[i] == _id) {
                for (uint256 j = i; j < _task_ids.length - 1; ++j) {
                    _task_ids[j] = _task_ids[j + 1];
                }
                _task_ids.pop();
                return;
            }
        }
    }

    // Returns an array of current task IDs
    function get_task_ids() public view returns (uint256[] memory) {
        return _task_ids;
    }

    // Returns an array of available tasks
    function get_tasks() public view returns (Task[] memory) {
        Task[] memory available_tasks = new Task[](_task_ids.length);
        for (uint256 i = 0; i < available_tasks.length; ++i) {
            uint256 id = _task_ids[i];
            available_tasks[i] = _tasks[id];
        }
        return available_tasks;
    }

    // Returns details of a specific task
    function get_task(uint256 _id)
        public
        view
        taskExists(_id)
        returns (Task memory)
    {
        Task memory task = _tasks[_id];
        return task;
    }

    // Returns the number of available tasks
    function number_of_tasks() public view returns (uint256) {
        return _task_ids.length;
    }

    // Returns the number of completed tasks
    function number_of_completed_tasks() public view returns (uint256) {
        return _completed_tasks_ids.length;
    }

    // Returns the number of incomplete tasks
    function number_of_incomplete_tasks() public view returns (uint256) {
        return _incomplete_tasks_ids.length;
    }

    // Update the arrays containing completed and incomplete tasks
    function _update_task_status_arrays() private {
        if (_tasks_state == _update_state) return;

        delete _completed_tasks_ids;
        delete _incomplete_tasks_ids;
        delete _completed_tasks;
        delete _incomplete_tasks;
        for (uint256 i = 0; i < _task_ids.length; ++i) {
            uint256 id = _task_ids[i];
            Task memory task = _tasks[id];
            if (task.completed) {
                _completed_tasks_ids.push(id);
                _completed_tasks.push(task);
            } else {
                _incomplete_tasks_ids.push(id);
                _incomplete_tasks.push(task);
            }
        }
        _tasks_state = _update_state;
    }

    // Returns IDs of completed tasks
    function get_completed_tasks_ids() public returns (uint256[] memory) {
        _update_task_status_arrays();
        return _completed_tasks_ids;
    }

    // Returns completed tasks
    function get_completed_tasks() public returns (Task[] memory) {
        _update_task_status_arrays();
        return _completed_tasks;
    }

    // Returns IDs of incomplete tasks
    function get_incomplete_tasks_ids() public returns (uint256[] memory) {
        _update_task_status_arrays();
        return _incomplete_tasks_ids;
    }

    // Returns incomplete tasks
    function get_incomplete_tasks() public returns (Task[] memory) {
        _update_task_status_arrays();
        return _incomplete_tasks;
    }

    // Check if a task is complete based on its ID
    function is_complete(uint256 _id)
        public
        view
        taskExists(_id)
        returns (bool)
    {
        return _tasks[_id].completed;
    }

    // Creates a new task
    function create_task(string memory _description)
        public
        onlyOwner
        updateState
    {
        _task_count++;
        _tasks[_task_count] = Task(_task_count, _description, false);
        _task_ids.push(_task_count);
        emit TaskCreated(_task_count, _description, false);
    }

    // Marks a task as completed
    function complete_task(uint256 _id)
        public
        onlyOwner
        taskExists(_id)
        updateState
    {
        Task storage task = _tasks[_id];
        task.completed = true;
        emit TaskCompleted(_id, task.description, task.completed);
    }

    // Marks all tasks as completed
    function complete_all_tasks() public onlyOwner updateState {
        for (uint256 i = 0; i < _task_ids.length; ++i) {
            uint256 id = _task_ids[i];
            _tasks[id].completed = true;
        }
        emit AllTasksCompleted();
    }

    // Deletes a specific task
    function delete_task(uint256 _id)
        public
        onlyOwner
        taskExists(_id)
        updateState
    {
        Task memory task = _tasks[_id];
        delete _tasks[_id];
        _delete_task_id(_id);
        emit TaskDeleted(task.id, task.description, task.completed);
    }

    // Deletes completed tasks
    function delete_completed_tasks() public onlyOwner updateState {
        _update_task_status_arrays();
        _task_ids = _incomplete_tasks_ids;
        emit CompletedTasksDeleted(_completed_tasks);
        delete _completed_tasks_ids;
        delete _completed_tasks;
        ++_update_state;
        _tasks_state = _update_state;
    }

    // Deletes all tasks
    function delete_all_tasks() public onlyOwner updateState {
        delete _task_ids;
        // or
        // _task_ids = new uint256[](0);
        _task_count = 0;
    }

    // Updates the description of a task
    function update_task(uint256 _id, string memory _description)
        public
        onlyOwner
        taskExists(_id)
    {
        _tasks[_id].description = _description;
        emit TaskUpdated(_id, _description, _tasks[_id].completed);
    }

    // Updates the description of a task
    function update_task(uint256 _id, bool _completed)
        public
        onlyOwner
        taskExists(_id)
        updateState
    {
        _tasks[_id].completed = _completed;
        emit TaskUpdated(_id, _tasks[_id].description, _completed);
    }

    // Overload of the previous method to allow for optional arguments
    function update_task(
        uint256 _id,
        string memory _description,
        bool _completed
    ) public onlyOwner taskExists(_id) updateState {
        require(_task_exists(_id), "Task does not exist!");
        _tasks[_id].description = _description;
        _tasks[_id].completed = _completed;
        emit TaskUpdated(_id, _description, _completed);
    }
}
