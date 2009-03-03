From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v3)
Date: Tue, 03 Mar 2009 08:22:12 -0800
Message-ID: <1236097332.22399.8.camel@nimitz>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
	 <1236095764-19325-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757149AbZCDAcy@vger.kernel.org>
In-Reply-To: <1236095764-19325-3-git-send-email-danms@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 2009-03-03 at 10:56 -0500, Dan Smith wrote:
> As suggested by Dave[1], this provides us a way to make the copy-in and
> copy-out processes symmetric.  CR_COPY_ARRAY() provides us a way to do
> the same thing but for arrays.  It's not critical, but it helps us unify
> the checkpoint and restart paths for some things.

Did you convince Nathan that this ends up being a good idea?

-- Dave
