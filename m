From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/7] [RFC] Allow cgroup hierarchies to be created with no
	bound subsystems
Date: Thu, 2 Apr 2009 01:17:02 -0700
Message-ID: <6599ad830904020117m5c29c5fdi17bc1b18c7e5028d@mail.gmail.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105137.24154.34890.stgit@menage.corp.google.com>
	<49BF470D.8080600@cn.fujitsu.com>
	<6599ad830903310145l7b24ad0vb4462f94390ac264@mail.gmail.com>
	<49D30C44.8050802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49D30C44.8050802-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 31, 2009 at 11:40 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> and what's the concern to not print out all the tasks? the buffer
>>> limit of seqfile?
>>
>> Yes.
>>
>
> Hmm, I just had a try, and I found we don't need to worry about this,
> seqfile can handle output that larger than PAGE_SIZE well.
>

But only as a kmalloc, so it gets progressively harder to satisfy as
the record size increases.

Paul
