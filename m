From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Simplify memory controller and resource counter I/O
Date: Fri, 05 Oct 2007 09:34:23 +0530
Message-ID: <4705B7C7.9090905@linux.vnet.ibm.com>
References: <46F9DD4F.50806@google.com>
	<6599ad830710041755w3ed8b1fgd3dfbe7a8e0fc6c5@mail.gmail.com>
	<4705B02E.8040701@linux.vnet.ibm.com>
	<6599ad830710042038g6066d8b0i9308244d2710e563@mail.gmail.com>
	<4705B36A.7000301@linux.vnet.ibm.com>
	<6599ad830710042054i6729870g896cedc3767fa2cf@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710042054i6729870g896cedc3767fa2cf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 10/4/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> Paul Menage wrote:
>>> On 10/4/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>>> Forbidding writing to the root resource counter is a policy decision
>>>> I am unable to make up my mind about. It sounds right, but unless
>>>> we have a notion of unlimited resources, I am a bit concerned about
>>>> taking away this flexibility.
>>> One big reason for doing this is to make virtualization easier - if
>>> you expect not to be able to write to your root cgroup's limits files,
>>> then it's easier to make them non-writeable for a virtual server.
>>>
>> Can't we handle that through file system permissions? virtual servers
>> will not run as root
> 
> They'll probably run as root in their own user namespace if at all.
> But that's the point - if userspace in general expects root cgroup
> limits to not be writeable (the same way that root cpusets
> cpus/mems_allowed files aren't writeable) then virtual servers will
> break less.
> 

In that case, let's have a value that says RES_COUNTER_INFINITY
and set the root to that value and make the root cgroup limits
read-only.

>> But system administrators deal with memory in MB and GB. When you go
>> to buy memory, you don't specify, I need 1 << 30 or 2^30 bytes of
>> memory :-). Most administrators track their memory using these
>> quantifiers.
> 
> OK, so maybe we should just fold a call to memparse() into
> cgroup_write_uint? Then we could use the plain write_uint() method in
> the control file?
> 

Yes, either that way or add a strategy function, that would take
the string input from the user and convert it to unsigned long long
value. I am ok with either approach.

>>>> Do read_uint() and write_uint(), just read and write unsigned
>>>> integers?
>>> Correct.
>>>
>> Oops.. that would be problem, what if I wanted to set my limit to
>> unsigned long long max?
> 
> Sorry, I wasn't getting your point about the sizing. No, they're u64
> values. (And I guess could be changed to unsigned long long if people
> preferred).
> 

I would prefer unsigned long long, but we could get more opinions.

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
