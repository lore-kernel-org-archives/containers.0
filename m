From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Mon, 20 Oct 2008 15:49:05 +0200
Message-ID: <48FC8C51.2050108__11437.0246454657$1224532190$gmane$org@fr.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1224286383.1848.65.camel@nimitz>
	<20081020111002.GQ15171@hawkmoon.kerlabs.com>
	<48FC86B2.8000606@fr.ibm.com> <48FC8C30.6040409@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FC8C30.6040409-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
>>> I'm afraid that we are forgetting to take the best from both
>>> approaches...
>> I agree with Louis.
>>
>> I played with Oren's patchset and tryed to port it on x86_64. I was able
>> to sys_checkpoint/sys_restart but if you remove the restoring of the
>> general registers, the restart still works. I am not an expert on asm,
>> but my hypothesis is when we call sys_checkpoint the registers are saved
>> on the stack by the syscall and when we restore the memory of the
>> process, we restore the stack and the stacked registers are restored
>> when exiting the sys_restart. That make me feel there is an important
>> gap between external checkpoint and internal checkpoint.
>>
>> Dmitry's patchset is nice too, but IMO, it goes too far from what we
> 
> I think you are talking about Andrey.

Yes :)
