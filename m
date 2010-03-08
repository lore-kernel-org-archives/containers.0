From: Kees Cook <kees@ubuntu.com>
Subject: Re: [PATCH RFC] Define CAP_SYSLOG
Date: Mon, 8 Mar 2010 10:58:18 -0800
Message-ID: <20100308185818.GN20744@outflux.net>
References: <20100305205607.GA31791@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100305205607.GA31791@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi Serge,

On Fri, Mar 05, 2010 at 02:56:07PM -0600, Serge E. Hallyn wrote:
> Privileged syslog operations currently require CAP_SYS_ADMIN.  Split
> this off into a new CAP_SYSLOG privilege which we can sanely take away
> from a container through the capability bounding set.

Seems like a good idea, but it'll require code changes in libcap2,
libcap-ng, as well as manpages.

I support the idea -- more stuff needs to be extracted from CAP_SYS_ADMIN,
but this is a nice distinct subsystem to do now.

Acked-By: Kees Cook <kees.cook@canonical.com>

-- 
Kees Cook
Ubuntu Security Team
