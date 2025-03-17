import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sourcemanv2/datatype.dart';
import 'package:sourcemanv2/event.dart';
import 'package:sourcemanv2/managers/env_var_manager.dart';
import 'package:sourcemanv2/managers/profile_manager.dart';

class ProfileAccordion extends StatefulWidget {
  final String documentKey;

  const ProfileAccordion({required this.documentKey, super.key});

  @override
  State<StatefulWidget> createState() => _ProfileAccordionState();
}

class _ProfileAccordionState extends State<ProfileAccordion> {
  late EventManager events;

  @override
  Widget build(BuildContext context) {
    events = Provider.of<EventManager>(context);
    ProfileManager profileManager = Provider.of<ProfileManager>(context);
    List<Profile> profiles = profileManager.findProfilesByDocumentKey(widget.documentKey);
    List<Widget> sections = [];
    Profile defaultProfile = profiles.firstWhere((p) => p.name == "default");
    for (var i = 0; i < profiles.length; i++) {
      Profile p = profiles[i];
      if (p.name == "default") {
        defaultProfile = p;
      } else {
        Widget section = ProfileAccordionSection(
          documentKey: widget.documentKey,
          profileKey: p.key,
          key: UniqueKey(),
        );
        sections.add(section);
      }
    }
    Widget section = ProfileAccordionSection(
      documentKey: widget.documentKey,
      profileKey: defaultProfile.key,
      defaultOpen: true,
      key: UniqueKey(),
    );
    sections.insert(0, section);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: sections,),
        IconButton(
          onPressed: () {}, 
          tooltip: "add env profile",
          icon: const Icon(Icons.add)
        )
      ]
    );
  }
}

class ProfileAccordionSection extends StatefulWidget {
  final bool? defaultOpen;
  final String documentKey;
  final String profileKey;
  const ProfileAccordionSection({
    required this.documentKey, 
    required this.profileKey, 
    this.defaultOpen,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _ProfileAccordionSectionState();
}

class _ProfileAccordionSectionState extends State<ProfileAccordionSection> {
  late EventManager events;
  String title = "?";
  bool showContent = false;
  StreamSubscription? profileOpenSubscription;
  late ProfileOpenEvent profileOpenEvent;

  @override
  void initState() {
    if (widget.defaultOpen == true) {
      showContent = true;
      profileOpenEvent = ProfileOpenEvent(isDefault: true, profileKey: widget.profileKey);
    } else {
      profileOpenEvent = ProfileOpenEvent(isDefault: false, profileKey: widget.profileKey);
    }
    
    super.initState();
  }

  @override
  void dispose() {
    profileOpenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    events = Provider.of<EventManager>(context);
    profileOpenSubscription ??= events.listen<ProfileOpenEvent>(_toggleSelfDown); 
    ProfileManager profileManager = Provider.of<ProfileManager>(context);
    EnvVarManager envVarManager = Provider.of<EnvVarManager>(context);
    List<EnvVar> envVars = envVarManager.findEnvVarsByProfileKey(widget.profileKey);
    
    List<Widget> envVarWidgets = _initEnvVars(envVars);
    Profile? p = profileManager.findProfileByKey(widget.documentKey, widget.profileKey);
    if (p != null) {
      title = p.name;
    }

    return Card(
      // margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          // The title
          ListTile(
            title: Text(title),
            trailing: IconButton(
              icon: Icon(showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                _toggleProfile();
              },
            ),
          ),
          // Show or hide the content based on the state
          showContent
            ? Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: envVarWidgets,
              ),
            )
            : Container()
        ]
      ),
    );
  }

  List<Widget> _initEnvVars(List<EnvVar> vars) {
    List<Widget> envVars = [];
    for (var j = 0; j < vars.length; j++) {
      envVars.add(
        SizedBox(
          height: 40,
          child: TextFormField(
            key: UniqueKey(),
            initialValue: vars[j].value,
            onChanged: (String value) {
              vars[j].value = value;
              events.emit<ProfileOpenEvent>(profileOpenEvent);      
            },
          ),
        )
      );
    }
    return envVars;
  }

  void _toggleProfile() {
    if (widget.defaultOpen == true) {
      if (showContent == false) {
        events.emit<ProfileOpenEvent>(profileOpenEvent);
        setState(() {
          showContent = true;
        });
      } 
    } else {
      if (showContent == false) {
        events.emit<ProfileOpenEvent>(profileOpenEvent);
        setState(() {
          showContent = true;
        });
      }
    }
  }

  void _toggleSelfDown(ProfileOpenEvent event) {
    if (event != profileOpenEvent) {
      setState(() {
        showContent = false;
      });
    }
  }
}

