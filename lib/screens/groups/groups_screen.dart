import 'package:cluster/screens/groups/groups_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cluster/database/models.dart';
import 'package:cluster/repositories/repositories.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupRepository _groupRepository = GroupRepository();
  final ColleagueRepository _colleagueRepository = ColleagueRepository();
  List<Group> _groups = [];
  List<Group> _filteredGroups = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _groupRepository.getGroups();
      setState(() {
        _groups = groups;
        _filteredGroups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки групп: $e')),
      );
    }
  }

  void _filterGroups(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredGroups = _groups;
      } else {
        _filteredGroups = _groups.where((group) {
          return group.name.toLowerCase().contains(query.toLowerCase()) ||
              group.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GroupSearchDelegate(_groups, _filterGroups),
              );
            },
            tooltip: 'Поиск групп',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(context),
            tooltip: 'Создать группу',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredGroups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Нет групп'
                            : 'Группы не найдены',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredGroups.length,
                  itemBuilder: (context, index) {
                    return _buildGroupCard(_filteredGroups[index], context);
                  },
                ),
    );
  }

  Widget _buildGroupCard(Group group, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(group.description),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteGroup(group.id, context),
        ),
        onTap: () => _navigateToGroupDetail(context, group),
      ),
    );
  }

  void _navigateToGroupDetail(BuildContext context, Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(group: group),
      ),
    );
  }

  Future<void> _deleteGroup(int groupId, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление группы'),
          content: const Text('Вы уверены, что хотите удалить эту группу?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _groupRepository.deleteGroup(groupId);
        setState(() {
          _groups.removeWhere((group) => group.id == groupId);
          _filteredGroups = List.from(_groups);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа удалена')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления группы: $e')),
        );
      }
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateGroupDialog(onGroupCreated: _loadGroups);
      },
    );
  }
}

// Делегат для поиска
class GroupSearchDelegate extends SearchDelegate {
  final List<Group> groups;
  final Function(String) onFilterChanged;

  GroupSearchDelegate(this.groups, this.onFilterChanged);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onFilterChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredGroups = query.isEmpty
        ? groups
        : groups.where((group) {
            return group.name.toLowerCase().contains(query.toLowerCase()) ||
                group.description.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return ListTile(
          title: Text(group.name),
          subtitle: Text(group.description),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailScreen(group: group),
              ),
            );
          },
        );
      },
    );
  }
}

// Диалог создания группы
class CreateGroupDialog extends StatefulWidget {
  final VoidCallback onGroupCreated;

  const CreateGroupDialog({super.key, required this.onGroupCreated});

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ColleagueRepository _colleagueRepository = ColleagueRepository();
  List<Colleague> _allColleagues = [];
  List<int> _selectedColleagueIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColleagues();
  }

  Future<void> _loadColleagues() async {
    try {
      final colleagues = await _colleagueRepository.getColleagues();
      setState(() {
        _allColleagues = colleagues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки коллег: $e')),
      );
    }
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      final newGroup = Group(
        id: 0, // Будет присвоен автоматически
        name: _nameController.text,
        description: _descriptionController.text,
        memberIds: _selectedColleagueIds,
        createdAt: DateTime.now(),
        createdBy: 1, // ID текущего пользователя
      );

      try {
        final GroupRepository groupRepository = GroupRepository();
        await groupRepository.insertGroup(newGroup);
        Navigator.of(context).pop();
        widget.onGroupCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа создана')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка создания группы: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать группу'),
      content: _isLoading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название группы',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название группы';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание группы',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Участники группы:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._allColleagues.map((colleague) {
                      return CheckboxListTile(
                        title: Text(colleague.fullName),
                        subtitle: Text(colleague.position),
                        value: _selectedColleagueIds.contains(colleague.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedColleagueIds.add(colleague.id);
                            } else {
                              _selectedColleagueIds.remove(colleague.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _createGroup,
          child: const Text('Создать'),
        ),
      ],
    );
  }
}
