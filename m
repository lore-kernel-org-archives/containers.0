From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH][RFC] fs/exec.c: provide the correct process pid to the
	pipe helper
Date: Fri, 17 Sep 2010 09:52:03 -0500
Message-ID: <AANLkTinRNrmK_dm-3NEs9WpXOrZdG81QWHeJcU9XH3ot__26844.5276575678$1284735170$gmane$org@mail.gmail.com>
References: <1284663599-3549-1-git-send-email-wad@chromium.org>
	<20100917152639.0e88341a@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100917152639.0e88341a-3rXA9MLqAseW/qJFnhkgxti2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Eugene Teo <eugene-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 17, 2010 at 8:26 AM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrote:
> On Thu, 16 Sep 2010 13:59:59 -0500
> Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>
>> format_corename uses task_tgid_vnr to provide the numeric pid of a
>> core-dumping process. =A0For file-based coredumps, this is perfectly
>> satisfactory. =A0However, when the core_pattern contains a pipe, the
>> substituted PID is invalid in the namespace of the core_pattern pipe
>> helper, the init namespace.
>
> Nasty problem. I wonder how many more similar problems name spaces
> have introduced.
>
> But wouldn't it be better to place the helper into the name space(s)
> of the executed process? I guess it would risk breaking some existing
> set ups, but it seem like the cleanest solution to me. If you want
> to move the core dump out of the name space you could still
> use a named pipe or something like that with someone outside listening.
>
> That would also fix the net namespace problem you mentioned

I agree.  This was what I did first, but I wasn't confident I'd done
it right.  I'll go ahead and post the two patches I used to accomplish
it.   I'm happy to spend some time polishing them until they are
functionally correct, if everyone is happy enough with the approach.

more to come,
will
