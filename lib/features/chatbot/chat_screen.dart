import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/mock_farm_data.dart';
import '../../core/services/voice_recorder_service.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/voice_message_tile.dart';
import '../../core/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuery;
  const ChatScreen({super.key, this.initialQuery});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      role: 'ai',
      text:
                'Hello! I\'m FarmPilot AI. I\'m actively monitoring all racks, with current attention on Rack 3 for moisture and nutrient recovery.',
      sections: [
        _AISection(
          title: 'Current Farm Snapshot',
          content:
              'Rack A is in good condition. Rack B is slightly below optimal moisture and shows early nutrient stress, so I already prepared a recovery plan.',
          icon: Icons.insights_rounded,
        ),
      ],
      actions: ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'],
    ),
  ];
  bool _isTyping = false;

  List<String> get _currentRecommendations {
    for (final message in _messages.reversed) {
      if (message.role == 'ai') {
        final actions = message.actions ?? const <String>[];
        if (actions.isNotEmpty) return actions;
      }
    }
    return const ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'];
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuery!);
      });
    }
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery && 
        widget.initialQuery != null && 
        widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _isTyping = true;
    });

    _scrollToBottom();

    // Mock AI response with delay
    await Future.delayed(const Duration(milliseconds: 1400));

    final response = _getAIResponse(text.toLowerCase());
    if (mounted) {
      setState(() {
        _messages.add(response);
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendVoiceMessage(String path, int durationSeconds) async {
    setState(() {
      _messages.add(
        _ChatMessage(
          role: 'user',
          text: '',
          voicePath: path,
          voiceDurationSeconds: durationSeconds,
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          role: 'ai',
          text:
              'I received your voice message (${durationSeconds}s). '
              'Based on your question, here is the latest Rack B status.',
          sections: [
            const _AISection(
              title: 'Rack B snapshot',
              content:
                  'Moisture is recovering after the last irrigation pulse. '
                  'Temperature and pH remain within target range.',
              icon: Icons.mic_rounded,
            ),
          ],
          actions: ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'],
        ),
      );
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _showVoiceUnavailableSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording is available on mobile only')),
    );
  }

  Future<void> _pickAndSendPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null || !mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(role: 'user', text: '', imagePath: file.path),
        );
        _isTyping = true;
      });
      _scrollToBottom();

      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          final i = _messages.length - 1;
          _messages[i] = _ChatMessage(
            role: 'user',
            text: '',
            imageBytes: bytes,
            imagePath: kIsWeb ? null : file.path,
          );
        });
      }

      await Future.delayed(const Duration(milliseconds: 1400));

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'ai',
            text:
                'Thanks for the photo — I\'ve analysed the leaves.\n\n'
                'Early nitrogen stress is likely on Rack B (pale leaf colour). '
                'I\'ve logged a short irrigation pulse and adjusted the nutrient mix for the next cycle.',
            sections: [
              const _AISection(
                title: 'Photo analysis',
                content:
                    'Pale-green colouration detected. This matches early-stage nitrogen deficiency at seedling phase. Monitor for 2 hours after nutrient adjustment.',
                icon: Icons.image_search_rounded,
              ),
            ],
            actions: ['Suggest product?', 'Diagnose plant health', 'Monitor Rack B'],
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open photo picker: $e')),
      );
    }
  }

  _ChatMessage _getAIResponse(String query) {
    if (query.contains('how is rack a today') ||
        query.contains("how's rack a today") ||
        query.contains('rack a today')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Rack A is in good condition today. Core metrics are stable and no immediate corrective action is needed.',
        sections: [
          _AISection(
            title: 'Condition status',
            content:
                'Plant growth looks healthy, irrigation is balanced, and nutrient uptake appears stable for the current stage.',
            icon: Icons.eco_rounded,
          ),
        ],
        actions: ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'],
      );
    }

    if (query.contains('how is rack c today') ||
        query.contains("how's rack c today") ||
        query.contains('rack c today') ||
        query.contains('rack c')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Rack C is in good condition today. Core metrics are stable and no immediate corrective action is needed.',
        sections: [
          _AISection(
            title: 'Condition status',
            content:
                'Plant growth in Rack C looks healthy, irrigation is balanced, and nutrient uptake is stable for the current stage.',
            icon: Icons.eco_rounded,
          ),
        ],
        actions: ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'],
      );
    }

    if (query.contains('why did this happen') || query.contains('what happened')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Rack B moisture dropped because warmer ambient conditions accelerated substrate drying during the last cycle.',
        sections: [
          _AISection(
            title: 'Cause analysis',
            content:
                'Seedling-stage plants in Rack B are sensitive to rapid drying. I triggered short recovery irrigation to prevent stress.',
            icon: Icons.analytics_outlined,
            imageAssetPath: 'assets/images/why.png',
          ),
        ],
        actions: ['Burst water now', 'Monitor Rack B', 'Suggest product?'],
      );
    }

    if (query.contains('condition') || query.contains('is it okay') || query.contains('healthy')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Rack B plants are in good condition overall and currently recovering well. Growth is stable and no critical risk is detected now.',
        sections: [
          _AISection(
            title: 'Current condition',
            content:
                'Leaves remain structurally healthy and moisture correction is in progress. Continue monitoring and maintain nutrient balance.',
            icon: Icons.eco_rounded,
          ),
        ],
        actions: ['How is Rack B today?', 'Monitor Rack B', 'Suggest product?'],
      );
    }

    if (query.contains('diagnose plant health') ||
        query.contains('identified early-stage') ||
        query.contains('early stage') ||
        query.contains('nitrogen deficiency')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'I identified an early-stage nitrogen deficiency in Rack B. Leaves show pale-green coloration and this can reduce yield if untreated.',
        sections: [
          _AISection(
            title: 'Diagnosis details',
            content:
                'Nutrient uptake weakened after a warmer cycle accelerated substrate drying. At seedling stage, even a short nutrient gap can quickly show as pale leaves.',
            icon: Icons.help_outline_rounded,
            imageAssetPath: 'assets/images/nitrogendeficiency.png',
          ),
          _AISection(
            title: 'Solutions for your farm',
            content:
                'Use a short water burst to stabilize moisture, then apply a balanced nitrogen-forward nutrient set for 2-3 feed cycles.',
            icon: Icons.lightbulb_outline_rounded,
          ),
        ],
        actions: [
          'Suggest product?',
          'Burst water now',
          'Monitor Rack B',
        ],
      );
    }

    if (query.contains('need it urgently') || query.contains('urgent')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Here are the nearest supplies shops for immediate recovery treatment.',
        sections: [
          _AISection(
            title: 'Urgent plan',
            content:
                'Prioritize stores with in-stock nitrogen booster. Navigate directly and complete treatment within today.',
            icon: Icons.local_shipping_outlined,
          ),
        ],
        nearbyShops: _nearbySupplyShops,
        actions: ['Prefer online?', 'Burst water now', 'Monitor Rack B'],
      );
    }

    if (query.contains('prefer online')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Online options ready. You can order from Shopee or Lazada based on delivery speed and price.',
        products: _nutrientProducts,
        actions: ['Need it urgently?', 'Show budget options', 'Show premium options'],
      );
    }

    if (query.contains('burst water') ||
        query.contains('water burst') ||
        query.contains('burst irrigation')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Water burst activated for Rack B. A 30-second pulse has been executed to recover moisture safely.',
        sections: [
          _AISection(
            title: 'Burst action result',
            content:
                'Moisture recovery is now in progress. I will keep monitoring and trigger another short pulse only if the level remains below target.',
            icon: Icons.water_drop_rounded,
            imageAssetPath: 'assets/images/waterburst.png',
          ),
        ],
        actions: ['Monitor Rack B', 'Why did this happen?', 'Suggest product?'],
      );
    }

    if (query.contains('rack b') || query.contains('moisture')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Rack B is below optimal today. Moisture dropped and I have already triggered a short irrigation recovery.',
        sections: [
          _AISection(
            title: 'Today status',
            content:
                'Moisture is 72% (target ~82%), temperature is 24.8°C, and pH is 6.8. Irrigation was activated for 30 seconds to prevent root stress.',
            icon: Icons.auto_awesome_rounded,
          ),
          _AISection(
            title: 'Cause analysis',
            content:
                'The substrate dried faster due to warmer ambient conditions in the last 4 hours. Seedling-stage Romaine is more sensitive, so AI applied a short burst to quickly recover moisture.',
            icon: Icons.help_outline_rounded,
            imageAssetPath: 'assets/images/waterburst.png',
          ),
        ],
        actions: [
          'Burst water now',
          'Suggest product?',
          'Diagnose plant health',
          'Monitor Rack B',
        ],
      );
    }

    if (query.contains('product') ||
        query.contains('buy') ||
        query.contains('shop') ||
        query.contains('nutrient') ||
        query.contains('fertilizer') ||
        query.contains('suggest product') ||
        query.contains('suggest products') ||
        query.contains('shopee') ||
        query.contains('lazada')) {
      return _ChatMessage(
        role: 'ai',
        text: 'Here are suitable products based on Rack B symptoms and growth stage.',
        sections: [
          _AISection(
            title: 'Selection logic',
            content:
                'I prioritized products with balanced NPK, root support, and fast delivery options to stabilize early-stage nitrogen deficiency.',
            icon: Icons.psychology_rounded,
          ),
        ],
        products: _nutrientProducts,
        actions: [
          'Need it urgently?',
          'Show more budget options',
          'Show premium options',
        ],
      );
    }

    if (query.contains('harvest')) {
      return _ChatMessage(
        role: 'ai',
        text:
            'Rack B harvest is predicted in about 3 days if moisture and nutrient recovery stay on track.',
        sections: [
          _AISection(
            title: 'Harvest prep',
            content:
                'Prepare packaging and buyer scheduling for Rack B within 48 hours while maintaining stable irrigation cycles.',
            icon: Icons.task_alt_rounded,
          ),
        ],
        actions: ['Create reminders', 'Show sales channels'],
      );
    }

    return _ChatMessage(
      role: 'ai',
      text: MockFarmData.chatWorkflows['default']!,
      sections: [
        _AISection(
          title: 'Try asking',
          content:
              'Ask "How is Rack B today?", "Diagnose plant health", or "Suggest product?" for focused guidance.',
          icon: Icons.tips_and_updates_rounded,
        ),
      ],
      actions: ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'],
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FarmPilot AI', style: AppTypography.headlineMd.copyWith(color: AppColors.primary, fontSize: 18)),
                const Row(
                  children: [
                    AIPulseIndicator(size: 6),
                    SizedBox(width: 4),
                    Text('Online', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_comment_rounded, color: AppColors.onSurfaceVariant), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _messages.length) {
                  return const _TypingIndicator();
                }
                return _ChatBubble(message: _messages[i]);
              },
            ),
          ),
          // Quick suggestions
          _QuickSuggestions(
            suggestions: _currentRecommendations,
            onTap: _sendMessage,
          ),
          // Input bar
          _ChatInputBar(
            controller: _controller,
            onSend: () => _sendMessage(_controller.text),
            onVoiceRecorded: _sendVoiceMessage,
            onVoiceUnavailable: _showVoiceUnavailableSnackBar,
            onPhoto: _pickAndSendPhoto,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String text;
  final List<_AISection>? sections;
  final List<_NearbySupplyShop>? nearbyShops;
  final List<_ProductRecommendation>? products;
  final List<String>? actions;
  final String? voicePath;
  final int? voiceDurationSeconds;
  final Uint8List? imageBytes;
  final String? imagePath;

  _ChatMessage({
    required this.role,
    required this.text,
    this.sections,
    this.nearbyShops,
    this.products,
    this.actions,
    this.voicePath,
    this.voiceDurationSeconds,
    this.imageBytes,
    this.imagePath,
  });

  bool get isVoiceMessage =>
      voiceDurationSeconds != null && voiceDurationSeconds! > 0;

  bool get hasImage => imageBytes != null || imagePath != null;
}

class _AISection {
  final String title;
  final String content;
  final IconData icon;
  final String? imageAssetPath;
  const _AISection({
    required this.title,
    required this.content,
    required this.icon,
    this.imageAssetPath,
  });
}

class _ProductRecommendation {
  final String name;
  final String subtitle;
  final String shopeeUrl;
  final String lazadaUrl;
  final String? imageAssetPath;
  const _ProductRecommendation({
    required this.name,
    required this.subtitle,
    required this.shopeeUrl,
    required this.lazadaUrl,
    this.imageAssetPath,
  });
}

class _NearbySupplyShop {
  final String name;
  final String distance;
  final String operatingHours;
  final String stockStatus;
  final bool isLimitedStock;
  final String mapUrl;
  const _NearbySupplyShop({
    required this.name,
    required this.distance,
    required this.operatingHours,
    required this.stockStatus,
    required this.isLimitedStock,
    required this.mapUrl,
  });
}

const List<_NearbySupplyShop> _nearbySupplyShops = [
  _NearbySupplyShop(
    name: 'GreenGrow Supplies',
    distance: '2.4 miles away',
    operatingHours: 'Open until 6 PM',
    stockStatus: 'In Stock',
    isLimitedStock: false,
    mapUrl:
        'https://www.google.com/maps/search/?api=1&query=hydroponic+shop+near+me',
  ),
  _NearbySupplyShop(
    name: 'City Farm Hub',
    distance: '4.1 miles away',
    operatingHours: 'Open until 8 PM',
    stockStatus: 'Limited Stock',
    isLimitedStock: true,
    mapUrl:
        'https://www.google.com/maps/search/?api=1&query=farm+supply+store+near+me',
  ),
];

const List<_ProductRecommendation> _nutrientProducts = [
  _ProductRecommendation(
    name: 'Aptus N-BOOST 50ml',
    subtitle:
        'Nitrogen booster for early-stage deficiency recovery (same product on Shopee and Lazada)',
    shopeeUrl:
        'https://shopee.com.my/Aptus-N-BOOST-50ml-(Left-Turning-Amino-Acids-L-Amino-Acids-Nitrogen-Fertilizer-Organic-Nitrogen)-i.28804497.7705634315?extraParams=%7B%22display_model_id%22%3A71054056380%2C%22model_selection_logic%22%3A3%7D&sp_atk=9fed3164-a830-4da6-90ff-2859ed5a02bb&xptdk=9fed3164-a830-4da6-90ff-2859ed5a02bb',
    lazadaUrl:
        'https://www.lazada.com.my/products/pdp-i573822416-s1147616468.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Aorganic%252Bnitrogen%252Bbooster%252Bhydroponic%253Bnid%253A573822416%253Bsrc%253ALazadaMainSrp%253Brn%253Aaacb09fb1c8e9bbc80686d3d1b6bc405%253Bregion%253Amy%253Bsku%253A573822416_MY%253Bprice%253A97%253Bclient%253Adesktop%253Bsupplier_id%253A24341%253Bsession_id%253A%253Bbiz_source%253Ah5_internal%253Bslot%253A0%253Butlog_bucket_id%253A470687%253Basc_category_id%253A10000644%253Bitem_id%253A573822416%253Bsku_id%253A1147616468%253Bshop_id%253A7194%253BtemplateInfo%253A107880_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Selangor&price=97&priceCompare=skuId%3A1147616468%3Bsource%3Alazada-search-voucher%3Bsn%3Aaacb09fb1c8e9bbc80686d3d1b6bc405%3BoriginPrice%3A9700%3BdisplayPrice%3A9700%3BsinglePromotionId%3A-1%3BsingleToolCode%3AmockedSalePrice%3BvoucherPricePlugin%3A0%3Btimestamp%3A1778407775216&ratingscore=&request_id=aacb09fb1c8e9bbc80686d3d1b6bc405&review=&sale=1&search=1&source=search&spm=a2o4k.searchlist.list.0&stock=1',
    imageAssetPath: 'assets/images/NitrogenBooster.png',
  ),
  _ProductRecommendation(
    name: 'Liquid Kelp Fertilizer',
    subtitle: 'Seaweed/kelp organic concentrate to support recovery and reduce stress',
    shopeeUrl:
        'https://shopee.com.my/Serbajadi-Agromarine-Kelp-and-Seaweed-Organic-Fertiliser-Concentrate-Fertiliser-Baja-Air-Rumpai-Laut-Organik-200ml-i.306086331.9741419114?extraParams=%7B%22display_model_id%22%3A275001619533%2C%22model_selection_logic%22%3A3%7D&sp_atk=890a1e78-2605-4840-af95-5502f8b2555c&xptdk=890a1e78-2605-4840-af95-5502f8b2555c',
    lazadaUrl:
        'https://www.lazada.com.my/products/pdp-i1712974217-s26286802230.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Aliquid%252Bkelp%252Bfertilizer%252Bhydroponic%253Bnid%253A1712974217%253Bsrc%253ALazadaMainSrp%253Brn%253Ac692f6062f769a3265f2d08ef7ef5bff%253Bregion%253Amy%253Bsku%253A1712974217_MY%253Bprice%253A159.4%253Bclient%253Adesktop%253Bsupplier_id%253A300141516643%253Bsession_id%253A%253Bbiz_source%253Ah5_internal%253Bslot%253A16%253Butlog_bucket_id%253A470687%253Basc_category_id%253A10000644%253Bitem_id%253A1712974217%253Bsku_id%253A26286802230%253Bshop_id%253A918287%253BtemplateInfo%253A107880_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Wp%20Kuala%20Lumpur&price=159.4&priceCompare=skuId%3A26286802230%3Bsource%3Alazada-search-voucher%3Bsn%3Ac692f6062f769a3265f2d08ef7ef5bff%3BoriginPrice%3A15940%3BdisplayPrice%3A15940%3BsinglePromotionId%3A-1%3BsingleToolCode%3A-1%3BvoucherPricePlugin%3A0%3Btimestamp%3A1778409037863&ratingscore=4.816326530612245&request_id=c692f6062f769a3265f2d08ef7ef5bff&review=49&sale=226&search=1&source=search&spm=a2o4k.searchlist.list.16&stock=1',
    imageAssetPath: 'assets/images/liquidKlep.png',
  ),
  _ProductRecommendation(
    name: 'Hydroponic A+B Nutrient Set',
    subtitle: 'RapidGrow 4L Liquid A+B set for hydroponic leafy vegetables',
    shopeeUrl:
        'https://shopee.com.my/RapidGrow-4L-Liquid-AB-Fertilizers-Baja-AB-Hidroponik-Fertigasi-Sayuran-(2L-A-2L-B)-i.53135024.11405984392?extraParams=%7B%22display_model_id%22%3A261383161903%2C%22model_selection_logic%22%3A3%7D&sp_atk=37bca430-e624-43b4-81cc-0b93d2145920&xptdk=37bca430-e624-43b4-81cc-0b93d2145920',
    lazadaUrl:
        'https://www.lazada.com.my/products/pdp-i2220136346-s11466642238.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253ARapidGrow%252B4L%252BLiquid%252BAB%252BFertilizers%252B-%252BBaja%252BAB%252B%25252F%252BHidroponik%252B%25252F%252BFertigasi%252B%25252F%252BSayuran%252B%2525282L%252BA%252B%25252B%252B2L%252BB%252529%253Bnid%253A2220136346%253Bsrc%253ALazadaMainSrp%253Brn%253A449e1125c2c3fd04f8e6e0bf53b39d62%253Bregion%253Amy%253Bsku%253A2220136346_MY%253Bprice%253A26.9%253Bclient%253Adesktop%253Bsupplier_id%253A100006467%253Bsession_id%253A%253Bbiz_source%253Ahttps%253A%252F%252Fwww.lazada.com.my%252F%253Bslot%253A0%253Butlog_bucket_id%253A470687%253Basc_category_id%253A10000644%253Bitem_id%253A2220136346%253Bsku_id%253A11466642238%253Bshop_id%253A52918%253BtemplateInfo%253A107880_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Selangor&price=26.9&priceCompare=skuId%3A11466642238%3Bsource%3Alazada-search-voucher%3Bsn%3A449e1125c2c3fd04f8e6e0bf53b39d62%3BoriginPrice%3A2690%3BdisplayPrice%3A2690%3BsinglePromotionId%3A-1%3BsingleToolCode%3A-1%3BvoucherPricePlugin%3A0%3Btimestamp%3A1778409149275&ratingscore=4.968&request_id=449e1125c2c3fd04f8e6e0bf53b39d62&review=125&sale=491&search=1&source=search&spm=a2o4k.searchlist.list.0&stock=1',
    imageAssetPath: 'assets/images/AB.png',
  ),
];

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  Future<void> _openExternalLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the link')),
      );
    }
  }

  Widget _buildUploadedImage(_ChatMessage msg) {
    if (msg.imageBytes != null) {
      return Image.memory(msg.imageBytes!, width: 220, height: 160, fit: BoxFit.cover);
    }
    if (msg.imagePath != null && !kIsWeb) {
      return Image.file(File(msg.imagePath!), width: 220, height: 160, fit: BoxFit.cover);
    }
    return const SizedBox(
      width: 220,
      height: 120,
      child: Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAI = message.role == 'ai';
    final sections = message.sections ?? const <_AISection>[];
    final nearbyShops = message.nearbyShops ?? const <_NearbySupplyShop>[];
    final products = message.products ?? const <_ProductRecommendation>[];
    final actions = message.actions ?? const <String>[];
    final recommendedActions = isAI
        ? (actions.isNotEmpty
            ? actions
            : const ['How is Rack B today?', 'Diagnose plant health', 'Suggest product?'])
        : const <String>[];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI ? AppColors.surfaceContainerLowest : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAI ? 4 : 20),
                  bottomRight: Radius.circular(isAI ? 20 : 4),
                ),
                boxShadow: AppShadows.card,
                border: isAI ? Border.all(color: AppColors.outlineVariant) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildUploadedImage(message),
                    ),
                    if (message.text.isNotEmpty) const SizedBox(height: 6),
                  ],
                  if (message.isVoiceMessage)
                    VoiceMessageTile(
                      durationSeconds: message.voiceDurationSeconds!,
                      filePath: message.voicePath,
                      isOutgoing: !isAI,
                      accentColor: isAI ? AppColors.primary : AppColors.secondary,
                      iconColor: Colors.white,
                      labelColor: isAI ? AppColors.onSurface : Colors.white,
                    )
                  else if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: AppTypography.bodyMd.copyWith(
                        color: isAI ? AppColors.onSurface : Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  if (isAI && sections.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...sections.map(
                      (section) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(section.icon, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section.title,
                                    style: AppTypography.labelLg.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    section.content,
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.onSurface,
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                  ),
                                  if (section.imageAssetPath != null) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        section.imageAssetPath!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isAI && products.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Suggested products',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...products.map(
                      (product) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.subtitle,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            if (product.imageAssetPath != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  product.imageAssetPath!,
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _openExternalLink(context, product.shopeeUrl),
                                    icon: const Icon(Icons.storefront_rounded, size: 16),
                                    label: const Text('Shopee'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _openExternalLink(context, product.lazadaUrl),
                                    icon: const Icon(Icons.shopping_bag_rounded, size: 16),
                                    label: const Text('Lazada'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isAI && nearbyShops.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Solutions for your farm',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Need it urgently?',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...nearbyShops.map(
                      (shop) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    shop.name,
                                    style: AppTypography.labelLg.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: shop.isLimitedStock
                                        ? Colors.orange.withValues(alpha: 0.14)
                                        : Colors.green.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    shop.stockStatus,
                                    style: AppTypography.caption.copyWith(
                                      color: shop.isLimitedStock
                                          ? Colors.orange.shade800
                                          : Colors.green.shade800,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${shop.distance} • ${shop.operatingHours}',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _openExternalLink(context, shop.mapUrl),
                                icon: const Icon(Icons.map_outlined, size: 16),
                                label: const Text('Navigate on Google Maps'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prefer online?',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (isAI && recommendedActions.isNotEmpty) const SizedBox(height: 2),
                ],
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.onSurfaceVariant, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),
                bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => Container(
                  width: 7, height: 7,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3 + _ctrl.value * 0.7),
                    shape: BoxShape.circle,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;
  const _QuickSuggestions({
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.4),
              borderRadius: AppRadius.fullRadius,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(suggestions[i],
                style: AppTypography.labelLg.copyWith(color: AppColors.primary, fontSize: 13)),
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final void Function(String path, int durationSeconds) onVoiceRecorded;
  final VoidCallback onVoiceUnavailable;
  final void Function(ImageSource source) onPhoto;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.onVoiceRecorded,
    required this.onVoiceUnavailable,
    required this.onPhoto,
  });

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  final _recorder = VoiceRecorderService.instance;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<void> _handleVoice() async {
    if (!_recorder.isSupported) {
      widget.onVoiceUnavailable();
      return;
    }

    if (_isRecording) {
      try {
        final result = await _recorder.stop();
        if (!mounted) return;
        setState(() => _isRecording = false);
        if (result != null) {
          widget.onVoiceRecorded(result.path, result.durationSeconds);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save recording: $e')),
        );
      }
      return;
    }

    try {
      await _recorder.start();
      if (!mounted) return;
      setState(() => _isRecording = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 8, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: _isRecording ? 'Recording… tap mic to send' : 'Ask about your farm...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: _isRecording ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontSize: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.xxlRadius,
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xxlRadius,
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xxlRadius,
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                suffixIcon: PopupMenuButton<ImageSource>(
                  icon: const Icon(Icons.attach_file_rounded, color: AppColors.onSurfaceVariant),
                  tooltip: 'Attach photo',
                  onSelected: widget.onPhoto,
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: ImageSource.gallery,
                      child: Row(
                        children: [
                          Icon(Icons.photo_library_rounded),
                          SizedBox(width: 10),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                    if (!kIsWeb)
                      const PopupMenuItem(
                        value: ImageSource.camera,
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt_rounded),
                            SizedBox(width: 10),
                            Text('Camera'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: hasText ? widget.onSend : _handleVoice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _isRecording ? AppColors.secondary : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: _isRecording ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
              child: Icon(
                _isRecording
                    ? Icons.stop_rounded
                    : (hasText ? Icons.send_rounded : Icons.mic_rounded),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
