/**
 * Agora Controller — Real token generation with fallback to mock
 */

const APP_ID = process.env.AGORA_APP_ID || '';
const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || '';

let RtcTokenBuilder, RtcRole;
try {
  const agoraToken = require('agora-token');
  RtcTokenBuilder = agoraToken.RtcTokenBuilder;
  RtcRole = agoraToken.RtcRole;
} catch (e) {
  console.warn('agora-token not available, using mock tokens');
}

/**
 * POST /api/agora/token
 */
exports.generateToken = async (req, res) => {
  try {
    const { channelName, uid = 0, role = 'publisher' } = req.body;

    if (!channelName) {
      return res.status(400).json({ error: 'channelName is required.' });
    }

    let token;
    if (RtcTokenBuilder && APP_ID && APP_CERTIFICATE) {
      const agoraRole = role === 'audience' ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;
      const expirationTimeInSeconds = 3600; // 1 hour
      const currentTimestamp = Math.floor(Date.now() / 1000);
      const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

      token = RtcTokenBuilder.buildTokenWithUid(
        APP_ID, APP_CERTIFICATE, channelName, parseInt(uid), agoraRole, privilegeExpiredTs
      );
    } else {
      // Mock token
      token = `mock_agora_token_${channelName}_${uid}_${Date.now()}`;
    }

    return res.status(200).json({
      message: 'Token generated',
      token,
      appId: APP_ID || 'agora_placeholder_app_id',
      channelName,
    });
  } catch (error) {
    console.error('Agora Token Error:', error);
    return res.status(500).json({ error: 'Failed to generate token.' });
  }
};

/**
 * POST /api/agora/recording/start
 */
exports.startRecording = async (req, res) => {
  try {
    const { channelName, uid } = req.body;
    if (!channelName) return res.status(400).json({ error: 'channelName is required.' });

    // Cloud recording is an Agora REST API call — mock for now
    const mockResourceId = `res_${Date.now()}`;
    const mockSid = `sid_${Date.now()}`;

    return res.status(200).json({
      message: 'Recording started',
      resourceId: mockResourceId,
      sid: mockSid,
    });
  } catch (error) {
    console.error('Recording Start Error:', error);
    return res.status(500).json({ error: 'Failed to start recording.' });
  }
};

/**
 * POST /api/agora/recording/stop
 */
exports.stopRecording = async (req, res) => {
  try {
    const { cname, resourceId, sid } = req.body;
    if (!cname || !resourceId || !sid) {
      return res.status(400).json({ error: 'cname, resourceId, and sid are required.' });
    }

    return res.status(200).json({
      message: 'Recording stopped',
      fileList: `s3://dndstylists-recordings/${cname}/video_${sid}.mp4`,
    });
  } catch (error) {
    console.error('Recording Stop Error:', error);
    return res.status(500).json({ error: 'Failed to stop recording.' });
  }
};
