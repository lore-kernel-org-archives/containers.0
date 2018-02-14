From: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 19:01:52 +0100
Message-ID: <794929ce-0ecb-4c93-d51e-e94fcf749cfa__19148.3822455213$1518631230$gmane$org@metux.net>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<60748622.exvCVAzLTp@blindfold>
	<e924b563-44c6-d678-a6cc-1181f4b820d5@metux.net>
	<4042675.OEy7g9C5ya@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4042675.OEy7g9C5ya@blindfold>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-S6VGOU4v5edDinCvNWH78Q@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 14.02.2018 18:50, Richard Weinberger wrote:

>> hmm, now it works, but only when strace'ing it.
>> that's really strange.
> 
> On my box, with my patch applied, also busybox works now.

hmm, w/o strace, too ?
Which version are you using ? I've got 1.27.2

>> But still I wonder whether user_ns really solves my problem, as I don't
>> want to create sandboxed users, but only private namespaces just like
>> on Plan9.
> 
> Well, I'd be surprised if that works out of the box.
> Since you're posting on LKML I assumed you're hacking the kernel to support
> plan9-alike namespaces...

Yes, that's the plan :)


--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org -- +49-151-27565287
