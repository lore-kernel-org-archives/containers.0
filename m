From: Philipp Wendler <ml-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>
Subject: Re: Using overlayfs in (unprivileged) namespace
Date: Mon, 15 Feb 2016 13:30:15 +0100
Message-ID: <56C1C4D7.8030406@philippwendler.de>
References: <56C1B0C6.6080806@philippwendler.de> <56C1BAE2.30209@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56C1BAE2.30209-6AxghH7DbtA@public.gmane.org>
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

Dear Nikolay,

thank you for your answer.

Am 15.02.2016 um 12:47 schrieb Nikolay Borisov:
> On 02/15/2016 01:04 PM, Philipp Wendler wrote:

>> $ ./userns_child_exec -m -U -z bash
>>
>> Then execute the following commands:
>>
>> mkdir /tmp/namespace-overlay
>> cd /tmp/namespace-overlay
>> mkdir mount lower upper work
>> touch lower/test
>> mount -t overlayfs n -o lowerdir=lower,upperdir=upper,workdir=work mount
>> rm mount/test
>>
>> The last command gives:
>>> rm: cannot remove 'mount/test': Operation not permitted
>>
>> This fails even if /tmp does not have "nodev" set (with "nodev" it would
>> be expected to fail of course).
>> Interestingly, it even fails if I start userns_child_exec as root,
>> not sure why.
>> Outside namespaces everything works as expected.
> 
> Wouldn't using the device cgroup with the respective major/minor numbers
> allowed rectify the situation?

I am not sure how.
I have no special setup for the devices cgroup.
The file devices.list of the cgroup in which my process is contains
"a *:* rwm".
So I think the devices cgroup would already allow me to create that
device node, and I have no way to grant additional permissions with the
cgroup, right?
At least that is how I understand the documentation for the devices cgroup.

> Also, have you done any tracing trying to
> figure out where exactly is this failing? E.g. using ftrace?

Sorry, no, I don't know how to do this.
I have looked into ftrace now, but I didn't find a way how to see which
function is responsible for letting the rm fail.
The kernel documentation on ftrace is quite overwhelming, so maybe I
have missed something.
Do you have by chance a more specific pointer to what would help me?

Greetings, Philipp
