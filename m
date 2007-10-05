From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Simplify memory controller and resource counter I/O
Date: Fri, 05 Oct 2007 09:15:46 +0530
Message-ID: <4705B36A.7000301@linux.vnet.ibm.com>
References: <46F9DD4F.50806@google.com>
	<6599ad830710041755w3ed8b1fgd3dfbe7a8e0fc6c5@mail.gmail.com>
	<4705B02E.8040701@linux.vnet.ibm.com>
	<6599ad830710042038g6066d8b0i9308244d2710e563@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710042038g6066d8b0i9308244d2710e563-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
>> Forbidding writing to the root resource counter is a policy decision
>> I am unable to make up my mind about. It sounds right, but unless
>> we have a notion of unlimited resources, I am a bit concerned about
>> taking away this flexibility.
> 
> One big reason for doing this is to make virtualization easier - if
> you expect not to be able to write to your root cgroup's limits files,
> then it's easier to make them non-writeable for a virtual server.
> 

Can't we handle that through file system permissions? virtual servers
will not run as root

>>>> One arguable drawback to this patch is that the use of memparse() is
>>>> lost in the cleanup. Having said that, given the existing of shell
>>>> arithmetic, it's not clear to me that typing
>>>>
>> memparse(), makes it so much easier, we need to use it.
>>
>>>> echo $[2<<30] > memory.limit
>>>>
>> Very geeky! I don't like it personally
> 
> Why do you dislike it? Do you really believe that anyone using this
> interface by hand isn't going to know that MB is 2^20 and GB is 2^30?
> 

But system administrators deal with memory in MB and GB. When you go
to buy memory, you don't specify, I need 1 << 30 or 2^30 bytes of
memory :-). Most administrators track their memory using these
quantifiers.

>> Do read_uint() and write_uint(), just read and write unsigned
>> integers?
> 
> Correct.
> 

Oops.. that would be problem, what if I wanted to set my limit to
unsigned long long max?

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
