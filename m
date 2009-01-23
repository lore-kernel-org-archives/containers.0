From: Paul Menage <menage@google.com>
Subject: Re: [PATCH] cgroup: Fix root_count when mount fails due to busy
	subsystem
Date: Fri, 23 Jan 2009 08:59:10 -0800
Message-ID: <6599ad830901230859p5453b166tfb384caad210f84b@mail.gmail.com>
References: <20090123004703.25103.29754.stgit@menage.corp.google.com>
	 <20090123102253.GF15188@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760020AbZAWQ70@vger.kernel.org>
In-Reply-To: <20090123102253.GF15188@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: akpm@linux-foundation.org, serue@us.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org

On Fri, Jan 23, 2009 at 2:22 AM, Ingo Molnar <mingo@elte.hu> wrote:
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -1115,8 +1115,10 @@ static void cgroup_kill_sb(struct super_block *sb) {
>>       }
>>       write_unlock(&css_set_lock);
>>
>> -     list_del(&root->root_list);
>> -     root_count--;
>> +     if (!list_empty(&root->root_list)) {
>> +             list_del(&root->root_list);
>> +             root_count--;
>> +     }
>
> That's ugly. It is _much_ cleaner to always keep the link head consistent
> - i.e. initialize it with INIT_LIST_HEAD()

It is initialized with INIT_LIST_HEAD().

> and then remove from it via
> list_del_init().

There's not much point doing list_del_init() rather than list_del()
here since we're about to delete the root.

>
> That way the error path will do the right thing automatically, and there's
> no need for that ugly "if !list_empty" construct either.

The important part here is avoiding decrementing root_count.

So the code could equally be:

if (!list_empty(&root->root_list)) {
  root_count--;
}
list_del(&root->root_list);

but what I have in this patch seems more straightforward. It's
actually how the code used to be before it was removed as a
"redundant" check by a patch that I unfortunately didn't get a chance
to read properly (or Ack) because I was too snowed under with other
work.

Paul
