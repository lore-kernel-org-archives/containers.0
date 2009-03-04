From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] s390: Expose a constant for the number of words
	representing the CRs
Date: Tue, 03 Mar 2009 16:59:56 -0800
Message-ID: <1236128396.22399.29.camel@nimitz>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
	 <1236095764-19325-2-git-send-email-danms@us.ibm.com>
	 <1236096494.22399.5.camel@nimitz>  <87d4cyrtr0.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756301AbZCDBAV@vger.kernel.org>
In-Reply-To: <87d4cyrtr0.fsf@caffeine.danplanet.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 2009-03-03 at 16:56 -0800, Dan Smith wrote:
> DH> This doesn't do a lot of good unless it gets used in the base s390
> DH> code.  Otherwise, why not just define it near its use in the c/r
> DH> code?
> 
> I intended to replace all uses, but I just found one place I missed,
> but I think that's it.  If you know of other places that it's used in
> the s390 code, other than in compat_ptrace.h and ptrace.h please point
> them out.

My only knowledge of where else it was used came from you. :)

-- Dave
