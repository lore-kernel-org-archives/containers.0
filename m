From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/8] Revert commit 8827c288feb7810185aa7c2e37537202fc709869
Date: Thu, 20 Aug 2009 11:17:14 +0800
Message-ID: <4A8CC03A.4010807__43365.0271305398$1250738368$gmane$org@cn.fujitsu.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>	
	<20090818235812.22531.76212.stgit@menage.mtv.corp.google.com>	
	<4A8CB62F.8030504@cn.fujitsu.com>	
	<6599ad830908191941x6ee47d58x295c29f80f8c624c@mail.gmail.com>	
	<4A8CBEDC.6010709@cn.fujitsu.com>
	<6599ad830908192013p328a2256o8c807a160e25a9a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908192013p328a2256o8c807a160e25a9a3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Wed, Aug 19, 2009 at 8:11 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> As you said, the 2 patches differ just in using different var/func
>> names, so rebasing shouldn't be hard but maybe a bit boring.
>>
> 
> Yes - it's a fair amount of work for no real gain.
> 

Ok, I won't insist on how it should be done.
