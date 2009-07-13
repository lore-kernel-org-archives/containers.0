From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Mon, 13 Jul 2009 14:02:08 -0500
Message-ID: <1247511728.15106.1.camel@merlyn>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	 <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org, Oren Laaden <orenl@cs.columbia.edu>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

On Tue, 2009-07-07 at 12:26 -0700, Dan Smith wrote:
> Changes in v2:
>  - Check for data in the TCP out-of-order queue and fail if present

Why?  It seems that this would cause checkpoints to fail unexpectedly,
and is probably unnecessary in a migration scenario, because the peer
will retransmit the segments given appropriate ACKs.

  --  John

