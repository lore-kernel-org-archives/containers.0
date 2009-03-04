From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v3)
Date: Wed, 04 Mar 2009 12:18:05 -0800
Message-ID: <8763ip9h4y.fsf@caffeine.danplanet.com>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
	<1236095764-19325-3-git-send-email-danms@us.ibm.com>
	<20090304140129.35e1ad97@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752666AbZCDUSX@vger.kernel.org>
In-Reply-To: <20090304140129.35e1ad97@thinkcentre.lan> (Nathan Lynch's message
	of "Wed, 4 Mar 2009 14:01:29 -0600")
Sender: linux-kernel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

NL> Drop the semicolon ^

Thanks.

NL> You might want to employ __must_be_array() or similar to catch
NL> misuse.

Ooh, nice.

NL> Misuse might also be prevented by providing some documentation :)

Agreed.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
