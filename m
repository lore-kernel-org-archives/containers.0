From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Mon, 13 Jul 2009 12:10:28 -0700
Message-ID: <87zlb8l7q3.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-3-git-send-email-danms@us.ibm.com>
	<1247511728.15106.1.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1247511728.15106.1.camel@merlyn> (John Dykstra's message of "Mon\, 13 Jul 2009 14\:02\:08 -0500")
Sender: netdev-owner@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org, Oren Laaden <orenl@cs.columbia.edu>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

JD> Why?  It seems that this would cause checkpoints to fail
JD> unexpectedly,

Well, there are other places where the checkpoint will fail with EBUSY
because something is in a transitional state.

JD> and is probably unnecessary in a migration scenario, because the
JD> peer will retransmit the segments given appropriate ACKs.

Cool, sounds like we can punt on this particular one... Thanks :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
