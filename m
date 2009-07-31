From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Fri, 31 Jul 2009 19:35:48 +0000
Message-ID: <1249068948.1104.0.camel@Maple>
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
> +       CKPT_COPY(op, hh->tcp.last_synq_overflow, sk->last_synq_overflow);

This sock field was removed from the mainline kernel by commit
a0f82f64e26929776c58a5c93c2ecb38e3d82815.

  --  John

