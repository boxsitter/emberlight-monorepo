import 'package:bessie/common/constants/colors.dart';
import 'package:flutter/material.dart';

import '../../common/constants//sizes.dart';
import '../../common/widgets/containers/rounded_container.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';

class ResponsiveDesignScreen extends StatelessWidget {
  const ResponsiveDesignScreen(
      {super.key = const ValueKey('ResponsiveDesignScreen')});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(
        desktop: ResponsiveDesignDesktop(),
        tablet: ResponsiveDesignTablet(),
        mobile: ResponsiveDesignMobile());
  }
}

class ResponsiveDesignDesktop extends StatelessWidget {
  const ResponsiveDesignDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure uniformity
        children: [
          // FIRST ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: BessRoundedContainer(
                  height: 450,
                  backgroundColor: BessColors.red,
                  child: const Center(child: Text('Widget 1')),
                ),
              ),
              const SizedBox(width: BessSizes.md),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BessRoundedContainer(
                      height: 215,
                      backgroundColor: BessColors.peach,
                      child: const Center(child: Text('Widget 2')),
                    ),
                    const SizedBox(height: BessSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: BessRoundedContainer(
                            height: 215,
                            backgroundColor: BessColors.rosewater,
                            child: const Center(child: Text('Widget 3')),
                          ),
                        ),
                        const SizedBox(width: BessSizes.md),
                        Expanded(
                          child: BessRoundedContainer(
                            height: 215,
                            backgroundColor: BessColors.green,
                            child: const Center(child: Text('Widget 4')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BessSizes.md), // Space between rows
      
          // SECOND ROW
          Row(
            children: [
              Expanded(
                flex: 2,
                child: BessRoundedContainer(
                  height: 220,
                  backgroundColor: BessColors.blue,
                  child: const Center(child: Text('Widget 5')),
                ),
              ),
              const SizedBox(width: BessSizes.md),
              Expanded(
                child: BessRoundedContainer(
                  height: 220,
                  backgroundColor: BessColors.mauve,
                  child: const Center(child: Text('Widget 6')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResponsiveDesignTablet extends StatelessWidget {
  const ResponsiveDesignTablet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [
          // FIRST ROW
          Row(
            children: [
              Expanded(
                flex: 2,
                child: BessRoundedContainer(
                  height: 450,
                  backgroundColor: Colors.red.withValues(alpha: 0.5),
                  child: const Center(child: Text('Widget 1')),
                ),
              ),
              const SizedBox(width: BessSizes.md),
              Expanded(
                flex: 2,
                child: Column(
                  spacing: 20,
                  children: [
                    BessRoundedContainer(
                      height: 215,
                      backgroundColor: Colors.orange.withValues(alpha: 0.5),
                      child: const Center(child: Text('Widget 2')),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: BessRoundedContainer(
                            height: 215,
                            backgroundColor: Colors.amber.withValues(alpha: 0.5),
                            child: const Center(child: Text('Widget 3')),
                          ),
                        ),
                        const SizedBox(width: BessSizes.md),
                        Expanded(
                          child: BessRoundedContainer(
                            height: 215,
                            backgroundColor: Colors.green.withValues(alpha: 0.5),
                            child: const Center(child: Text('Widget 4')),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
      
          // SECOND ROW
          Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              BessRoundedContainer(
                height: 220,
                width: double.infinity,
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                child: const Center(child: Text('Widget 5')),
              ),
              const SizedBox(width: BessSizes.md),
              BessRoundedContainer(
                height: 220,
                width: double.infinity,
                backgroundColor: Colors.purple.withValues(alpha: 0.2),
                child: const Center(child: Text('Widget 6')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResponsiveDesignMobile extends StatelessWidget {
  const ResponsiveDesignMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [
          BessRoundedContainer(
            height: 200,
            backgroundColor: Colors.red.withValues(alpha: 0.5),
            child: const Center(child: Text('Widget 1')),
          ),
          BessRoundedContainer(
            height: 200,
            backgroundColor: Colors.orange.withValues(alpha: 0.5),
            child: const Center(child: Text('Widget 2')),
          ),
          BessRoundedContainer(
            height: 200,
            backgroundColor: Colors.amber.withValues(alpha: 0.5),
            child: const Center(child: Text('Widget 3')),
          ),
          BessRoundedContainer(
            height: 200,
            backgroundColor: Colors.green.withValues(alpha: 0.5),
            child: const Center(child: Text('Widget 4')),
          ),
          BessRoundedContainer(
            height: 200,
            backgroundColor: Colors.blue.withValues(alpha: 0.5),
            child: const Center(child: Text('Widget 5')),
          ),
          BessRoundedContainer(
            height: 200,
            backgroundColor: Colors.purple.withValues(alpha: 0.5),
            child: const Center(child: Text('Widget 6')),
          ),
        ],
      ),
    );
  }
}
