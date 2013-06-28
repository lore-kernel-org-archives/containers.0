From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
	container are killed by OOM
Date: Fri, 28 Jun 2013 18:52:41 +0000
Message-ID: <20130628185241.GA27358@mail.hallyn.com>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
	<20130625132432.GA4098@sergelap>
	<CAMcjixZtW0KdAmLXyDoGFqL2qh4aEgdGjBYJWrPESFMz0dvELw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMcjixZtW0KdAmLXyDoGFqL2qh4aEgdGjBYJWrPESFMz0dvELw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aaron Staley <aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Aaron Staley (aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org):
> Hi Serge,
> 
> Thanks a lot. Would you know of any workarounds outside of forcing every
> write to sync to disk (which kills performance)? Perhaps some settings in
> the container I can set?  Unfortunately, modifying dirty_background_ratio
>  and dirty_expire_centiseconds globally (/etc/sysctl.conf) as suggested by
> the serverfault answer will not stop the OOM kills.

Sorry i haven't replied yet have I - no, I'm afraid I don't have any
good ideas offhand.  I think this is something that's going to have
to be fixed in the kernel, and there's really nothing you can do
in the container.  I could be wrong.

Over the next few days I'm going to be taking a fresh look at the
behaviors of the various controllers (at least as documented) for
the sake of thinking about configuration api - perhaps the answer
will become clear to me as I do that.

-serge
