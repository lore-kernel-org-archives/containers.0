From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 4 Aug 2009 16:17:42 -0500
Message-ID: <20090804211742.GC13499@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com> <20090804205241.GF10275@us.ibm.com> <878whzl2cs.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878whzl2cs.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> SH> Does this re-use of tmp make sense?  (It only would if
> SH> dev_alloc_skb() did a generic prealloc for any subsequent
> SH> skb_clone() which i don't think is the case)
> 
> No, this is cruft.
> 
> SH> Also, do you need any kind of lock on the queue to make this walk
> SH> safe, or do ensure below (sorry i'm slow and haven't gotten there)
> SH> that all tasks with an open fd for either end of this sock are
> SH> frozen?
> 
> Hmm, it seems that holding the lock while processing the queue isn't
> really the way to go.  Perhaps comparing the pid of the other end of
> the socket against the list in the context is best?

I don't understand.  Which pid?
