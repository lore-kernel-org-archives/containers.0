From: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Subject: Re: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Thu, 12 Jun 2008 22:34:48 +0900 (JST)
Message-ID: <27043861.1213277688814.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080612131748.GB8453@us.ibm.com>
	<20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
	<20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com>
	<20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080612131748.GB8453-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

----- Original Message -----
>> Just a question:
>> What happens when a thread (not thread-group-leader) changes its ns by
>> ns-cgroup ? not-allowed ?
>
>I don't quite understand the question.  I assume you're asking whether
>your cgroup, when composed with ns, will refuse a task in cgroup /cg/1/2
>from being able to
>
>	mkdir /cg/1/2/3
>	echo $$ > /cg/1/2/3/tasks
>
>or
>
>	unshare(CLONE_NEWNS)
>
>which the ns cgroup would allow, and what your cgroup would do in that
>case.  If your question ("not-allowed ?") is about ns cgroup behavior
>then please rephrase.

Ah, sorry. I'm just curious. (and I should read the code before making
quiestion.)

Assume a thread group contains threadA, threadB, threadC.

I wanted to ask "Can threadA, and threadB, and threadC
be in different cgroups ? And if so, how ns cgroup handles it ?"

Maybe I don't understand ns cgroup.

Thanks,
-Kame
