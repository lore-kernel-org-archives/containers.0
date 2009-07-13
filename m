From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Mon, 13 Jul 2009 09:52:09 +0900
Message-ID: <20090713095209.d8b6e566.kamezawa.hiroyu__44453.9432683543$1247446500$gmane$org@jp.fujitsu.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>
	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>
	<20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<4A554B54.3080903@embeddedalley.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A554B54.3080903-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Vladislav D. Buzov" <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Cc: Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 08 Jul 2009 18:43:48 -0700
"Vladislav D. Buzov" <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> wrote:

> KAMEZAWA Hiroyuki wrote:

> > 2 points.
> >  - Do we have to check this always we account ?
> >   
> What are the options? Every N pages? How to select N?
> 
I think you can reuse Balbir's softlimit event counter. (see v9.)


> > If this is true, "set limit" should be checked to guarantee this.
> > plz allow minus this for avoiding mess.
> Setting the memory controller cgroup limit and the notification
> threshold are two separate operations. There isn't any "mess," just some
> validation testing for reporting back to the source of the request. When
> changing the memory controller limit, we ensure the threshold limit is
> never allowed "negative." At most, the threshold limit will be equal the
> memory controller cgroup limit. Otherwise, the arithmetic and
> conditional tests during the operational part of the software becomes
> more complex, which we don't want.
> 
Hmm, then, plz this interface put under "set_limit_mutex".

Thanks,
-Kame
