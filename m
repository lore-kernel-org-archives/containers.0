From: Philipp Wendler <ml-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>
Subject: Re: Using overlayfs in (unprivileged) namespace
Date: Mon, 15 Feb 2016 19:47:49 +0100
Message-ID: <56C21D55.7080102@philippwendler.de>
References: <56C1B0C6.6080806@philippwendler.de>
	<20160215181817.GA23391@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160215181817.GA23391@ubuntumail>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello Serge,

Am 15.02.2016 um 19:18 schrieb Serge Hallyn:
> Quoting Philipp Wendler (ml-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org):
>> I would like to mount an overlayfs inside unprivileged user and mount
>> namespaces (i.e., the user creating the namespaces is a regular user
>> with no special privileges).
>> This works mostly fine, but it fails as soon as I try to delete a file
>> which exists in the "lower" directory of the overlay,
>> because overlayfs then needs to create a "whiteout" file,
>> for which it uses a device node with 0/0 device number
>> (https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt),
>> but I do not have the permission to create device nodes.
>>
>> Is there any way to make overlayfs work fully in my situation,
>> without requiring additional privileges?
>> If not, is this something that could be made work in the future?
>> Of course, creating arbitrary devices nodes is something that cannot be
>> granted to an unprivileged user, but in this case it is only a specific
>> device node with device numbers 0/0, and it is a kernel module creating
>> the device node on behalf of me.
>>
>> I am currently using Linux 4.2. To reproduce the problem,
> 
> Exactly what version from where?
> 
> It sounds to me like you're hitting
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1531747

Thank you for pointing this out!
This bug is different from my original problem, but now that that one is
solved I tried to reproduce this Ubuntu bug, and indeed I am hitting it,
too.

Greetings, Philipp
