From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Fwd: Porting checkpoint system to arm: write_file error
Date: Thu, 29 Oct 2009 09:07:15 -0500
Message-ID: <20091029140715.GD15713@us.ibm.com>
References: <44a110670910271824h50ff7e9dp3e87becac6380293@mail.gmail.com>
	<44a110670910282213g79d29cf0h6b1012e7a5f090eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <44a110670910282213g79d29cf0h6b1012e7a5f090eb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

The current version is ckpt-v18-dev for both linux-cr and user-cr.

-serge

Quoting Jerf gefera (jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> I am using ckpt-v13 (quite old one). if you know what is wrong, please point
> it out for me,
> Thank you very much.
> 
> ---------- Forwarded message ----------
> From: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, Oct 28, 2009 at 10:24 AM
> Subject: Porting checkpoint system to arm: write_file error
> To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
> 
> 
> hi all,
> The attachment is the img file and dmesg message.
> If I comment the code of cr_write_files in both checkpoint.c & restart.c,
> then i can checkpoint and restart the process(of cause, there are no file
> operations in the checkpointed process). it is strange.
> i hope you can point it out for me.
> Thank you very much!
> best wishes,
> gefera



> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
