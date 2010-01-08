From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
	notifications
Date: Thu, 7 Jan 2010 17:05:37 -0800
Message-ID: <6599ad831001071705k3954642eo3e04cef7a31e3727__18364.2022464939$1262912776$gmane$org@mail.gmail.com>
References: <cover.1262186097.git.kirill@shutemov.name>
	<9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
	<6599ad831001061701x72098dacn7a5d916418396e33@mail.gmail.com>
	<cc557aab1001070436w446ef85n55dd2af5e733f55e@mail.gmail.com>
	<4B46828C.5000703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B46828C.5000703-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 7, 2010 at 4:55 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> Use multi labels is much better:

I disagree with that - in the absence of a language that can do proper
destructor-based cleanup (i.e. a strictly controlled subset of C++ :-)
) I think it's clearer to have a single failure path where you can
clean up anything that needs to be cleaned up, without excessive
dependencies on exactly when the failure occurred. Changes then become
less error-prone.

Paul

>
> label4::
> =A0 =A0 =A0 =A0fput(cfile);
> label3:
> =A0 =A0 =A0 =A0eventfd_ctx_put(event->eventfd);
> label2:
> =A0 =A0 =A0 =A0fput(efile);
> label1:
> =A0 =A0 =A0 =A0kfree(event);
>
> compared to:
>
> +fail:
> + =A0 =A0 =A0 if (!IS_ERR(cfile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(cfile);
> +
> + =A0 =A0 =A0 if (event && event->eventfd && !IS_ERR(event->eventfd))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 eventfd_ctx_put(event->eventfd);
> +
> + =A0 =A0 =A0 if (!IS_ERR(efile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(efile);
> +
> + =A0 =A0 =A0 kfree(event);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
