From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4] user namespace fixes
Date: Mon, 17 Dec 2012 13:01:59 -0800
Message-ID: <87zk1cjsu0.fsf__11439.4541284584$1355778150$gmane$org@xmission.com>
References: <87txroxpgq.fsf@xmission.com>
	<CALCETrX2Fa-DuM+wkgsij7oiJXzCD8W6Phkv-MjgCDg_Ma6CTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrX2Fa-DuM+wkgsij7oiJXzCD8W6Phkv-MjgCDg_Ma6CTg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Mon, 17 Dec 2012 11:03:10 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Fri, Dec 14, 2012 at 2:01 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> These are fixes from Andys review of my user namespace tree.
>>
>> The first two patches are critical must fix fixes.
>>
>> The third patch fixing commit_creds is a nice to have but fixing it
>> would be good.
>>
>> Andy, Serge  if you could give these patches a once over to make certain
>> I am not doing something stupid.
>>
>> Thank you,
>> Eric
>>
>> ---
>>
>> Eric W. Biederman (4):
>>       Fix cap_capable to only allow owners in the parent user namespace to have caps.
>
> For whatever reason, I didn't get the actual email. 

How weird.

> Assuming this is
> 5e4a08476b50fa39210fca82e03325cc46b9c235:

It is the parent of that 5e4a08476b50fa39210fca82e03325cc46b9c235
520d9eabce18edfef76a60b7b839d54facafe1f9

But that should be close enough.

> Acked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>

Eric
