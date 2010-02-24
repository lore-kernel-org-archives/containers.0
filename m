From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2][LXC] Rename --directory option to --statefile
Date: Wed, 24 Feb 2010 10:11:50 -0800
Message-ID: <20100224181150.GA3276@us.ibm.com>
References: <20100224084108.GG18758@us.ibm.com> <4B84E80A.7060208@fr.ibm.com>
	<4B84E94E.3000406@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B84E94E.3000406-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
> Cedric Le Goater wrote:
>> On 02/24/2010 09:41 AM, Sukadev Bhattiprolu wrote:
>>> [See following mail for an intro to this patch set
>>>
 
>>> https://lists.linux-foundation.org/pipermail/containers/2010-February/023048.html] 
>>> 
>>>
>>>
>>> The --directory is misleading since the option seems to expect
>>> an checkpoint image file.
>>  sigh.
>>
>> This has some major impact on our side as it is a 9 year old API ...
>> We'll look into it to see how painful it is to change.

Ah, did not realize it caused that much pain.

>
> We can keep --directory and add --statefile.
> For --statefile option we can use a switch for IS_DIR, IS_REG.
>
> --directory becomes deprecated and we switch to the statefile option  
> step by step.
>
> Does it make sense ?

Yes, I think it will work.

BTW, what was the rationale for a directory ?  Is it meant to be used
with predefined file names in the specified directory ?

>
>   -- Daniel
