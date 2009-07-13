From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/3] Quick vmalloc vs kmalloc fix to the case where
	array  size is too large
Date: Tue, 14 Jul 2009 08:49:50 +0900
Message-ID: <20090714084950.2401d9a6.kamezawa.hiroyu__11368.7346260578$1247529226$gmane$org@jp.fujitsu.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230205.16778.11707.stgit@hastromil.mtv.corp.google.com>
	<4A5AA3E7.9070800@cn.fujitsu.com>
	<20090713150303.70ab5176.kamezawa.hiroyu@jp.fujitsu.com>
	<2f86c2480907130827u7d2b062bw26bbb80a8e3de657@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907130827u7d2b062bw26bbb80a8e3de657-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 13 Jul 2009 11:27:43 -0400
Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Mon, Jul 13, 2009 at 2:03 AM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > ???? why not using vmalloc() always ?
> >
> > Thanks,
> > -Kame
> >
> 
> The idea behind this patch is that in most cases, we want to use
> kmalloc for performance, but sometimes the array will be too big. See
> the previous thread (linked in the root message of this thread) for
> discussion of the issue.
> 
IIUC, this place, .../procs interface is not so important for performance
as to being allowed this ugly conding.

Thanks,
-Kame
