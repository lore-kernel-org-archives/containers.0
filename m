From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/8] Revert commit 8827c288feb7810185aa7c2e37537202fc709869
Date: Thu, 20 Aug 2009 11:11:24 +0800
Message-ID: <4A8CBEDC.6010709__15659.4220003628$1250738103$gmane$org@cn.fujitsu.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>	
	<20090818235812.22531.76212.stgit@menage.mtv.corp.google.com>	
	<4A8CB62F.8030504@cn.fujitsu.com>
	<6599ad830908191941x6ee47d58x295c29f80f8c624c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908191941x6ee47d58x295c29f80f8c624c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Aug 19, 2009 at 7:34 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> It's sure that reverting this commit makes things easier, but
>> rebasing this patchset shouldn't be hard. And this doesn't
>> sound a good reason to revert an innocent commit.
>>
> 
> The problem is that Ben's patch set starts with a patch that adds the
> "procs" file, and then a patch that fixes the namespace bug, and he
> and you used different names for variables/functions even though you
> were doing essentially the same thing. So rebasing would involve
> pretty much entirely rewriting the first patch and ditching the second
> - not just a case of fixing up some merge conflicts.
> 

Here we reintroduce the bug, and re-fix it with the essentially
same solution, this lazy way doesn't sound right to me.

As you said, the 2 patches differ just in using different var/func
names, so rebasing shouldn't be hard but maybe a bit boring.
