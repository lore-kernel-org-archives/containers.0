From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 13:37:02 -0500
Message-ID: <20100430183702.GA29585@us.ibm.com>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
 <20100430181946.GA26761@us.ibm.com>
 <87mxwkztjf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87mxwkztjf.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org, David Miller <davem@davemloft.net>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> SH> So I'm afraid you're going to have to do a slightly uglier thing
> SH> where you unshare_nsproxy_namespaces() and then
> SH> switch_task_namespaces() to the new nsproxy.
> 
> Well, I think that would be hidden in the nicer helper function I
> think I'll need, which I eluded to in the patch header.  This is just
> an RFC proof that it can be done in this manner, but I think a
> separate helper in nsproxy.c is in order to make it nice (and avoid
> the extra alloc/free of the netns that copy_namespaces() will create).
> Agreed?

Yup - thanks!

-serge
