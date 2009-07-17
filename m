From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Fri, 17 Jul 2009 08:03:36 +0530
Message-ID: <20090717023336.GF3576__31943.9577557661$1247798133$gmane$org@balbir.in.ibm.com>
References: <20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907131515h3c9622b5v309cf8f13d272bab@mail.gmail.com>
	<20090714100440.6283.A69D9226@jp.fujitsu.com>
	<9B7C6FE2-D946-4286-9537-C4A715997B89@embeddedalley.com>
	<20090716171530.GC3576@balbir.in.ibm.com>
	<FE89F36E-EB7E-4F11-887C-5371887C7D68@embeddedalley.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <FE89F36E-EB7E-4F11-887C-5371887C7D68-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Cc: Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

* Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> [2009-07-16 11:16:29]:

> 
> On Jul 16, 2009, at 10:15 AM, Balbir Singh wrote:
> 
> > Dan, if you are suggesting that we incrementally add features, I
> > completely agree with you, that way the code is reviewable and
> > maintainable. As we add features we need to
> 
> Right, this is all goodness.  My specific comments are this patch
> adds a new useful feature and it's been through a couple of iterations
> to make it more acceptable.  Let's post it, as it makes people aware
> of such a feature since it's currently in use and useful, and then
> continue the discussion about how to make it (and all of the cgroup
> features) better.  Otherwise, this is going to degenerate into a "do
> everything but nothing gets done" ongoing discussion and I'll
> quickly lose interest and move on the something else :-)
> 
> There are currently two discussions in progress.  One is about
> notification limits, which this feature patch adds.  We need to
> close this discussion with a more feature rich implementation
> that addresses both upper and lower notification, the semantics
> of this feature in a cgroup hierarchy, and in particular the
> behavior outside of the memory controller group.
> 
> The second discussion is about event delivery in cgroups.
> Linux already has many mechanisms, and some product
> implementations patch even more of their own into the kernel.
> Outside of these implementation details, we have to determine
> what is useful for a cgroup.  Are events just arbitrary (anything
> can send any kind of event)?  How do we pass  information?
> Is there some standard header?  How do we control this so
> the event target is identified and we prevent event floods?
> And many more.....
>

I think you keep missing my pointers to cgroupstats - a genetlink
based mechanism for event delivery and request/response applications.

 
> > 1. Look at reuse
> > 2. Make sure the design is sane and will not prohibit further
> > development.
> 
> 3. Contain the scope of work so I can do it without affecting
>      the work that pays my salary :-)
>

Not at the cost of (1) and (2) and a patient discussion around what is
being proposed. 

-- 
	Balbir
