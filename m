From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Thu, 16 Jul 2009 22:45:30 +0530
Message-ID: <20090716171530.GC3576@balbir.in.ibm.com>
References: <20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907131515h3c9622b5v309cf8f13d272bab@mail.gmail.com>
	<20090714100440.6283.A69D9226@jp.fujitsu.com>
	<9B7C6FE2-D946-4286-9537-C4A715997B89@embeddedalley.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9B7C6FE2-D946-4286-9537-C4A715997B89-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
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
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Id: containers.vger.kernel.org

* Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> [2009-07-14 12:13:32]:

> If you look at my presentation from the last ELC, you
> will see this patch is one small step of many to improve
> resource management.  This event notification discussion
> is important, but still just a tiny implementation detail in
> a bigger resource management scheme.  We need to
> make the small steps to make people aware of new features,
> write applications that utilize these features, and to
> perhaps discover something even better we aren't
> even considering.

Dan, if you are suggesting that we incrementally add features, I
completely agree with you, that way the code is reviewable and
maintainable. As we add features we need to

1. Look at reuse
2. Make sure the design is sane and will not prohibit further
development.

-- 
	Balbir
