From: "Subrata Modak" <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] Helper patches for PTY namespaces
Date: Sat, 12 Apr 2008 23:09:50 +0530
Message-ID: <bb33bcf20804121039u409ae37q2dead849ca24dfa@mail.gmail.com>
References: <20080412172933.GA19295@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2126432814=="
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20080412172933.GA19295-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============2126432814==
Content-Type: multipart/alternative;
	boundary="----=_Part_12360_30741121.1208021990130"

------=_Part_12360_30741121.1208021990130
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sukadev,

Any corresponding test cases for LTP. We just have UTS, PID & SYSVIPC
Namespace till now.

Regards--
Subrata

On Sat, Apr 12, 2008 at 10:59 PM, <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

>
> Some simple helper patches to enable implementation of multiple PTY
> (or device) namespaces.
>
>        [PATCH 1/4]: Propagate error code from devpts_pty_new
>        [PATCH 2/4]: Factor out PTY index allocation
>        [PATCH 3/4]: Move devpts globals into init_pts_ns
>        [PATCH 3/4]: Enable multiple mounts of /dev/pts
>
> This patchset is based on earlier versions developed by Serge Hallyn
> and Matt Helsley.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Regards & Thanks--
Subrata

------=_Part_12360_30741121.1208021990130
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sukadev,<br><br>Any corresponding test cases for LTP. We just have UTS, PID &amp; SYSVIPC Namespace till now.<br><br>Regards--<br>Subrata<br><br><div class="gmail_quote">On Sat, Apr 12, 2008 at 10:59 PM,  &lt;<a href="mailto:sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org">sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org</a>&gt; wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><br>
Some simple helper patches to enable implementation of multiple PTY<br>
(or device) namespaces.<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;[PATCH 1/4]: Propagate error code from devpts_pty_new<br>
 &nbsp; &nbsp; &nbsp; &nbsp;[PATCH 2/4]: Factor out PTY index allocation<br>
 &nbsp; &nbsp; &nbsp; &nbsp;[PATCH 3/4]: Move devpts globals into init_pts_ns<br>
 &nbsp; &nbsp; &nbsp; &nbsp;[PATCH 3/4]: Enable multiple mounts of /dev/pts<br>
<br>
This patchset is based on earlier versions developed by Serge Hallyn<br>
and Matt Helsley.<br>
<font color="#888888">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel&quot; in<br>
the body of a message to <a href="mailto:majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a><br>
More majordomo info at &nbsp;<a href="http://vger.kernel.org/majordomo-info.html" target="_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at &nbsp;<a href="http://www.tux.org/lkml/" target="_blank">http://www.tux.org/lkml/</a><br>
</font></blockquote></div><br><br clear="all"><br>-- <br>Regards &amp; Thanks--<br>Subrata

------=_Part_12360_30741121.1208021990130--


--===============2126432814==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
--===============2126432814==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ltp-list mailing list
Ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/ltp-list

--===============2126432814==--
