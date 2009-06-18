From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [patch 100/148] cgroups: convert tasks file to use a seq_file
	with shared pid array
Date: Thu, 18 Jun 2009 09:41:33 +0800
Message-ID: <4A399B4D.7030200@cn.fujitsu.com>
References: <200810190328.m9J3S4aB000311@imap1.linux-foundation.org>
	<6599ad830906162146n5a79b9b8n3b7dd0e72c72ab7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830906162146n5a79b9b8n3b7dd0e72c72ab7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> It just struck me that this patch broke access to the tasks file in
> the presence of multiple pid namespaces, since the pids in the cached
> pid array are always from the namespace of the last process to open

Hmm, so we have to keep namespace in mind whenever we deal with
pid..

> the file. Since I suspect no-one uses pid namespaces in production
> environments this probably isn't a show-stopper, but to be technically
> correct we need to maintain a list of cached pid arrays keyed by pid
> namespace. (This list should generally be very short, usually of
> length 1).
> 

Sounds feasible.
