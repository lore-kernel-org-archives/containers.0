From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and
 devices (v3)
Date: Wed, 10 Feb 2010 14:30:01 -0600
Message-ID: <20100210203001.GB23301@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
 <1265750713-15749-3-git-send-email-danms@us.ibm.com>
 <20100210172405.GB12251@us.ibm.com>
 <87pr4dgfdz.fsf@caffeine.danplanet.com>
 <4B7310AA.3090708@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B7310AA.3090708@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@cs.columbia.edu):
> 
> 
> Dan Smith wrote:
> >SH> What exactly is this == 0 case?  Does it mean 'use inherited
> >SH> netns'?
> >
> >It means it wasn't in the checkpoint image to begin with, so yeah,
> >kinda.
> 
> Maybe it's time to define CKPT_OBJREF_NULL for that ?
> (to make it easy to fold, in a separate patch please)

Honestly that wouldn't be any more helpful.  Just a comment.  The
problem is with 0 having a different meaning for each type of
object, so 0 or CKPT_OBJREF_NULL is equally unhelpful imo :)

/* wasn't in the checkpoint image, use the netns of restarting task */

or somesuch

-serge
