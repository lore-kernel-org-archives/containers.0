From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Wed, 20 May 2009 23:01:01 +0800
Message-ID: <d95d44a20905200801y7a75c4d2jf751a99dbd42ecf3@mail.gmail.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
	<20090520135944.GL4858@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090520135944.GL4858-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>
>> # cat mycontainer/memory.usage_in_bytes
>> 2875392
>> # echo 3000000 > mycontainer/memory.max_usage_in_bytes
>> # cat mycontainer/memory.max_usage_in_bytes
>> 3002368
>
> Where did you setup memory.limit_in_bytes?
>

Missing a command here. I have already run the command:

# echo 3000000 > mycontainer/memory.limit_in_bytes


as mentioned in previous email.
