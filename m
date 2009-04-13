From: Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH] Memory usage limit notification addition to memcg
Date: Mon, 13 Apr 2009 16:45:17 -0700
Message-ID: <298A09AD-495E-4671-84A1-B831826424A8@embeddedalley.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>
	<20090413160814.1c335d1d.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090413160814.1c335d1d.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


OK, I'll rewrite and resubmit the patch with suggested updates.
Comments below...

On Apr 13, 2009, at 4:08 PM, Andrew Morton wrote:

> We've run into problems in the past where a percentage number is too
> coarse on large-memory systems.
>
> Proabably that won't be an issue here, but I invite you to convince us
> of this ;)

The challenge here is that the absolute limit of the memcg can
be dynamically changed, so I wanted to avoid a couple of problems.
One is just a system configuration error where someone forgets
to modify both.  For example, if you start with the memcg limit of 100M,
and the notification limit to 80M, then come back and change the memcg
limit to 90M (or worse, < 80M) you now have a clearly incorrect
configuration.   Another problem is the operation isn't atomic, at some
point during the changes, even if you remember to do it correctly, you
will have the two values not representing what you really want.  It
could trigger an erroneous notification, or simply OOM kill before you
get the configuration correct.

If an integer number turns out to not be sufficient, we could change  
this
to some fixed point representation and adjust the arithmetic in the  
tests.
I believe the integer number will be fine, even in large memory systems.
This is just a notification model, if we want something more fine  
grained
I believe it would need different semantics.

> Does it support select()/poll()/eventfd()/etc?

No.  Unfortunately this is a cgroup implementation limitation.
My TODO list includes updating cgroups to allow this, using
this notification as an example.

> Stylistic trick: here, please add

Will do, including some others to get rid of ifdefs.

> ifdefs-in-c make kernel developers sad.

I know.  I'll make them go away.

I'll fix it up and resubmit shortly.

Thanks.

	-- Dan
