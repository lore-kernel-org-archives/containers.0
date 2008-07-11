From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] Transactional CGroup task attachment
Date: Fri, 11 Jul 2008 10:14:33 +0800
Message-ID: <4876C209.2010605@cn.fujitsu.com>
References: <6599ad830807092346j1fdb2ef9l2ca2b52e2e68096a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807092346j1fdb2ef9l2ca2b52e2e68096a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: =?UTF-8?B?IkRhaXN1a2UgTWl5YWthd2EgKOWuruW3nSDlpKfovJQpIg==?= <dmiyakawa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> This is an initial design for a transactional task attachment
> framework for cgroups. There are probably some potential simplications
> that I've missed, particularly in the area of locking. Comments
> appreciated.
> 

Though not so elegant, it sounds workable in practise.

Support for CGROUP_ATTACH_PROCESS adds complexity and some subsystems
may have to aware of this and write code to support it, but fortunately
it seems only numtasks needs to deal with this. Or we can implement
this new task attachment framework for CGROUP_ATTACH_THREAD mode only,
to see how good it works, and later we add support for
CGROUP_ATTACH_PROCESS.

And I'll do testing if this gets implemented. :)
