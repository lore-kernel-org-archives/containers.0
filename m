From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [PATCH RFC] Define CAP_SYSLOG
Date: Wed, 10 Mar 2010 17:19:19 -0800
Message-ID: <551280e51003101719t3c61da42ja5796b3d86b0126a@mail.gmail.com>
References: <20100305205607.GA31791@us.ibm.com>
	 <20100308185818.GN20744@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100308185818.GN20744@outflux.net>
Sender: linux-security-module-owner@vger.kernel.org
To: Kees Cook <kees@ubuntu.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Acked-by: Andrew G. Morgan <morgan@kernel.org>

I concur with Kees.

Cheers

Andrew

On Mon, Mar 8, 2010 at 10:58 AM, Kees Cook <kees@ubuntu.com> wrote:
> Hi Serge,
>
> On Fri, Mar 05, 2010 at 02:56:07PM -0600, Serge E. Hallyn wrote:
>> Privileged syslog operations currently require CAP_SYS_ADMIN. =A0Spl=
it
>> this off into a new CAP_SYSLOG privilege which we can sanely take aw=
ay
>> from a container through the capability bounding set.
>
> Seems like a good idea, but it'll require code changes in libcap2,
> libcap-ng, as well as manpages.
>
> I support the idea -- more stuff needs to be extracted from CAP_SYS_A=
DMIN,
> but this is a nice distinct subsystem to do now.
>
> Acked-By: Kees Cook <kees.cook@canonical.com>
>
> --
> Kees Cook
> Ubuntu Security Team
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
