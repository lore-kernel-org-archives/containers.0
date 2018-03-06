From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Userspace helper design
Date: Tue, 6 Mar 2018 13:51:14 -0800
Message-ID: <20180306215112.yn2ei6ypzo74hexv@ast-mbp.dhcp.thefacebook.com>
References: <20180306013448.GA6631@ircssh-2.c.rugged-nimbus-611.internal>
	<20180306014542.me6xtmyhhkystywz@ast-mbp>
	<CAMp4zn_c51SC5gvsk=pzTD7UCsid1DCyPhe-ScohZzrpyObu7g@mail.gmail.com>
	<20180306015351.5swdihfrisxb7226@ast-mbp>
	<307b9945-57d0-1178-32af-3837aaefae90@iogearbox.net>
	<CAMp4zn-Ga08OFF34BiQ+YqcnmKYrAbNgRKbK9UkG5TfVrjLqTw@mail.gmail.com>
	<fc4e2ea0-5bdc-a0be-c500-f55e7de8e1bd@iogearbox.net>
	<CAMp4zn8fdMYOpemqaQ_7+KAMmnVtHzi-wz_RqG_HJh15b81SDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMp4zn8fdMYOpemqaQ_7+KAMmnVtHzi-wz_RqG_HJh15b81SDg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 06, 2018 at 01:14:30PM -0800, Sargun Dhillon wrote:
> 
> So, would this verifier just ensure that no maps are accessed prior to
> the helper being called, XOR ensure that after the helper is called,
> no map values are accessed?

Nack on this design.
